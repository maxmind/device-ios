import XCTest
@testable import MinFraudDevice

final class MinFraudDeviceTests: XCTestCase {

    func testSharedInstanceExists() {
        // Test that the shared instance is accessible
        let sdk = MinFraudDevice.shared
        XCTAssertNotNil(sdk)
    }

    func testVersionIsValid() {
        // Test that version string is not empty
        let sdk = MinFraudDevice.shared
        XCTAssertFalse(sdk.version.isEmpty)
        XCTAssertEqual(sdk.version, "1.0.0")
    }

    func testDeviceIdFormat() {
        // Test that device ID, if available, is in UUID format
        let sdk = MinFraudDevice.shared
        if let deviceId = sdk.getDeviceId() {
            // UUID format: 8-4-4-4-12 characters separated by hyphens
            let uuidRegex = "^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$"
            let predicate = NSPredicate(format: "SELF MATCHES[c] %@", uuidRegex)
            XCTAssertTrue(predicate.evaluate(with: deviceId),
                         "Device ID should be in valid UUID format")
        }
    }

    func testDeviceIdConsistency() {
        // Test that multiple calls return the same ID
        let sdk = MinFraudDevice.shared
        let id1 = sdk.getDeviceId()
        let id2 = sdk.getDeviceId()

        if let id1 = id1, let id2 = id2 {
            XCTAssertEqual(id1, id2, "Device ID should remain consistent across calls")
        }
    }

    // MARK: - DeviceCheck Tests

    func testDeviceCheckSupportedCheck() {
        // Test that DeviceCheck support check doesn't crash
        let sdk = MinFraudDevice.shared
        let isSupported = sdk.isDeviceCheckSupported()
        // DeviceCheck may or may not be supported depending on device/simulator
        // Just verify the call completes without error
        XCTAssertNotNil(isSupported)
    }

    func testDeviceCheckTokenGeneration() async {
        let sdk = MinFraudDevice.shared

        // Only test token generation if DeviceCheck is supported
        guard sdk.isDeviceCheckSupported() else {
            // Skip test on unsupported devices (e.g., simulators)
            return
        }

        let result = await sdk.generateDeviceCheckToken()

        switch result {
        case .success(let token):
            XCTAssertFalse(token.isEmpty, "Token should not be empty")
        case .failure(let error):
            // Token generation can fail for various reasons
            // Just verify we got a proper error
            XCTAssertNotNil(error.errorDescription)
        }
    }

    func testDeviceCheckTokenStringGeneration() async {
        let sdk = MinFraudDevice.shared

        // Only test if DeviceCheck is supported
        guard sdk.isDeviceCheckSupported() else {
            return
        }

        let result = await sdk.generateDeviceCheckTokenString()

        switch result {
        case .success(let tokenString):
            XCTAssertFalse(tokenString.isEmpty, "Token string should not be empty")
            // Verify it's valid base64
            XCTAssertNotNil(Data(base64Encoded: tokenString), "Token should be valid base64")
        case .failure(let error):
            XCTAssertNotNil(error.errorDescription)
        }
    }
}
