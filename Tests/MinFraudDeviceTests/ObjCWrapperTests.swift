import XCTest
@testable import MinFraudDevice

final class ObjCWrapperTests: XCTestCase {
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(MockURLProtocol.self)
    }

    override func tearDown() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    // MARK: - MMSDKConfig

    func testObjCSDKConfigDefaults() {
        let config = ObjCSDKConfig(accountID: 12345)
        XCTAssertNotNil(config)
        XCTAssertEqual(config?.config.accountID, 12345)
        XCTAssertNil(config?.config.serverURL)
        XCTAssertFalse(config!.config.loggingEnabled)
        XCTAssertEqual(config?.config.collectionIntervalSeconds, 0)
    }

    func testObjCSDKConfigAllOptions() {
        let url = URL(string: "https://custom.example.com")!
        let config = ObjCSDKConfig(
            accountID: 99999,
            serverURL: url,
            loggingEnabled: true,
            collectionIntervalSeconds: 300
        )
        XCTAssertNotNil(config)
        XCTAssertEqual(config?.config.accountID, 99999)
        XCTAssertEqual(config?.config.serverURL, url)
        XCTAssertTrue(config!.config.loggingEnabled)
        XCTAssertEqual(config?.config.collectionIntervalSeconds, 300)
    }

    func testObjCSDKConfigReturnsNilForInvalidAccountID() {
        XCTAssertNil(ObjCSDKConfig(accountID: 0))
        XCTAssertNil(ObjCSDKConfig(accountID: -1))
    }

    func testObjCSDKConfigReturnsNilForInvalidCollectionInterval() {
        XCTAssertNil(
            ObjCSDKConfig(
                accountID: 12345,
                serverURL: nil,
                loggingEnabled: false,
                collectionIntervalSeconds: 60
            )
        )
        XCTAssertNil(
            ObjCSDKConfig(
                accountID: 12345,
                serverURL: nil,
                loggingEnabled: false,
                collectionIntervalSeconds: 299
            )
        )
    }

    // MARK: - MMDeviceTracker collectAndSend success

    func testObjCCollectAndSendSuccess() {
        MockURLProtocol.requestHandler = { _ in
            let data = Data("{\"stored_id\":\"abc123:hmac456\",\"ip_version\":6}".utf8)
            let response = HTTPURLResponse(
                url: URL(string: "https://test.maxmind.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, data)
        }

        let config = ObjCSDKConfig(accountID: 12345, serverURL: URL(string: "https://test.maxmind.com")!,
                                   loggingEnabled: false, collectionIntervalSeconds: 0)!
        let tracker = ObjCDeviceTracker(config: config)
        let expectation = expectation(description: "collectAndSend completes")

        tracker.collectAndSend { result, error in
            XCTAssertNil(error)
            XCTAssertNotNil(result)
            XCTAssertEqual(result?.trackingToken, "abc123:hmac456")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
        tracker.shutdown()
    }

    // MARK: - MMDeviceTracker collectAndSend failure

    func testObjCCollectAndSendServerError() {
        MockURLProtocol.requestHandler = { _ in
            let data = Data("{\"error\":\"Server Error\"}".utf8)
            let response = HTTPURLResponse(
                url: URL(string: "https://test.maxmind.com")!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }

        let config = ObjCSDKConfig(accountID: 12345, serverURL: URL(string: "https://test.maxmind.com")!,
                                   loggingEnabled: false, collectionIntervalSeconds: 0)!
        let tracker = ObjCDeviceTracker(config: config)
        let expectation = expectation(description: "collectAndSend fails")

        tracker.collectAndSend { result, error in
            XCTAssertNil(result)
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.domain, "\(SDKConfig.identifier).api")
            XCTAssertEqual(error?.code, 500)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
        tracker.shutdown()
    }

    // MARK: - MMTrackingResult

    func testObjCTrackingResultRedactsDescription() {
        let result = ObjCTrackingResult(result: TrackingResult(trackingToken: "secret"))
        XCTAssertEqual(result.trackingToken, "secret")
        XCTAssertFalse(result.description.contains("secret"))
    }

    // MARK: - CustomNSError bridging

    func testMinFraudDeviceErrorBridgesToNSError() {
        let error = MinFraudDeviceError.idfvUnavailable as NSError
        XCTAssertEqual(error.domain, SDKConfig.identifier)
        XCTAssertEqual(error.code, 1)
    }

    func testAPIErrorBridgesToNSError() {
        let error = APIError.serverError(statusCode: 403, message: "Forbidden") as NSError
        XCTAssertEqual(error.domain, "\(SDKConfig.identifier).api")
        XCTAssertEqual(error.code, 403)
    }
}
