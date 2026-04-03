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

    func testShutdownCancelsAutomaticCollection() async throws {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://test.maxmind.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data(self.validResponse.utf8))
        }

        let tracker = makeTracker(collectionIntervalSeconds: 300)

        // Give the auto-collection task a moment to start
        try await Task.sleep(nanoseconds: 50_000_000) // 50ms

        tracker.shutdown()

        // After shutdown, the task should be cancelled
        // Give it time to settle and verify no crashes
        try await Task.sleep(nanoseconds: 200_000_000) // 200ms
    }

    // MARK: - Public Init

    func testPublicInitCreatesTracker() {
        let config = SDKConfig(accountID: 12345)
        let tracker = DeviceTracker(config: config)
        // Should not crash
        tracker.shutdown()
    }
}
