import XCTest
@testable import MinFraudDevice

final class DeviceTrackerTests: XCTestCase {
    private var mockStorage = MockKeychainStorage()
    private var mockSession = makeSession()

    private static func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }

    override func setUp() {
        super.setUp()
        mockStorage = MockKeychainStorage()
        mockSession = DeviceTrackerTests.makeSession()
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    private var validResponse: String {
        "{\"stored_id\":\"abc123:hmac456\",\"ip_version\":6}"
    }

    private func makeTracker(
        accountID: Int = 99999,
        serverURL: URL? = URL(string: "https://test.maxmind.com"),
        collectionIntervalSeconds: Int = 0
    ) -> DeviceTracker {
        let sdkConfig = SDKConfig(
            accountID: accountID,
            serverURL: serverURL,
            collectionIntervalSeconds: collectionIntervalSeconds
        )
        let collector = DeviceDataCollector(
            storage: mockStorage,
            idfvProvider: { "TEST-IDFV" }
        )
        let apiClient = DeviceAPIClient(config: sdkConfig, session: mockSession)
        return DeviceTracker(
            config: sdkConfig,
            collector: collector,
            apiClient: apiClient,
            storage: mockStorage
        )
    }

    // MARK: - collectAndSend

    func testCollectAndSendReturnsTrackingResult() async throws {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://test.maxmind.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data(self.validResponse.utf8))
        }

        let tracker = makeTracker()
        let result = try await tracker.collectAndSend()

        XCTAssertEqual(result.trackingToken, "abc123:hmac456")
    }

    func testCollectAndSendSavesStoredIDToKeychain() async throws {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://test.maxmind.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data(self.validResponse.utf8))
        }

        let tracker = makeTracker()
        _ = try await tracker.collectAndSend()

        XCTAssertEqual(mockStorage.get(forKey: KeychainStorage.storedIDKey), "abc123:hmac456")
    }

    func testCollectAndSendSucceedsWhenStorageSaveFails() async throws {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://test.maxmind.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data(self.validResponse.utf8))
        }

        mockStorage.shouldFailOnSet = true
        let tracker = makeTracker()
        let result = try await tracker.collectAndSend()

        XCTAssertEqual(result.trackingToken, "abc123:hmac456")
        XCTAssertNil(mockStorage.get(forKey: KeychainStorage.storedIDKey))
    }

    func testCollectAndSendPropagatesAPIError() async {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://test.maxmind.com")!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data("{}".utf8))
        }

        let tracker = makeTracker()
        do {
            _ = try await tracker.collectAndSend()
            XCTFail("Expected error to be thrown")
        } catch let error as APIError {
            if case .serverError(let statusCode, _) = error {
                XCTAssertEqual(statusCode, 500)
            } else {
                XCTFail("Expected serverError")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testCollectAndSendThrowsWhenIDFVUnavailable() async {
        let sdkConfig = SDKConfig(
            accountID: 99999,
            serverURL: URL(string: "https://test.maxmind.com")
        )
        let collector = DeviceDataCollector(
            storage: mockStorage,
            idfvProvider: { nil }
        )
        let apiClient = DeviceAPIClient(config: sdkConfig, session: mockSession)
        let tracker = DeviceTracker(
            config: sdkConfig,
            collector: collector,
            apiClient: apiClient,
            storage: mockStorage
        )

        do {
            _ = try await tracker.collectAndSend()
            XCTFail("Expected error to be thrown")
        } catch let error as MinFraudDeviceError {
            XCTAssertEqual(error, .idfvUnavailable)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Shutdown

    func testAutomaticCollectionSendsRequest() async throws {
        let requestReceived = expectation(description: "Automatic collection sent a request")

        MockURLProtocol.requestHandler = { _ in
            requestReceived.fulfill()
            let response = HTTPURLResponse(
                url: URL(string: "https://test.maxmind.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data(self.validResponse.utf8))
        }

        let tracker = makeTracker(collectionIntervalSeconds: 300)

        await fulfillment(of: [requestReceived], timeout: 2)
        tracker.shutdown()
    }

    func testShutdownCancelsAutomaticCollection() async throws {
        let secondRequest = expectation(description: "Second automatic collection request")
        secondRequest.isInverted = true

        var requestCount = 0
        MockURLProtocol.requestHandler = { _ in
            requestCount += 1
            if requestCount >= 2 {
                secondRequest.fulfill()
            }
            let response = HTTPURLResponse(
                url: URL(string: "https://test.maxmind.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data(self.validResponse.utf8))
        }

        let tracker = makeTracker(collectionIntervalSeconds: 300)

        // Wait for the first automatic collection to complete.
        try await Task.sleep(nanoseconds: 500_000_000)

        tracker.shutdown()

        // Verify no further requests are made after shutdown.
        await fulfillment(of: [secondRequest], timeout: 1)
    }

    // MARK: - Public Init

    func testPublicInitCreatesTracker() {
        let config = SDKConfig(accountID: 12345)
        let tracker = DeviceTracker(config: config)
        // Should not crash
        tracker.shutdown()
    }
}
