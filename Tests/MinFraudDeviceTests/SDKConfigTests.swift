import XCTest
@testable import MinFraudDevice

final class SDKConfigTests: XCTestCase {

    func testDefaultValues() {
        let config = SDKConfig(accountID: 12345)

        XCTAssertEqual(config.accountID, 12345)
        XCTAssertNil(config.serverURL)
        XCTAssertFalse(config.loggingEnabled)
        XCTAssertEqual(config.collectionIntervalSeconds, 0)
    }

    func testCustomValues() {
        let url = URL(string: "https://custom.example.com")!
        let config = SDKConfig(
            accountID: 99999,
            serverURL: url,
            loggingEnabled: true,
            collectionIntervalSeconds: 300
        )

        XCTAssertEqual(config.accountID, 99999)
        XCTAssertEqual(config.serverURL, url)
        XCTAssertTrue(config.loggingEnabled)
        XCTAssertEqual(config.collectionIntervalSeconds, 300)
    }

    func testDefaultHosts() {
        XCTAssertEqual(SDKConfig.defaultIPv6Host, "d-ipv6.mmapiws.com")
        XCTAssertEqual(SDKConfig.defaultIPv4Host, "d-ipv4.mmapiws.com")
        XCTAssertEqual(SDKConfig.endpointPath, "/device/ios")
    }
}
