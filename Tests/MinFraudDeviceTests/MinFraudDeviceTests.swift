import XCTest
import Security
@testable import MinFraudDevice

final class MinFraudDeviceTests: XCTestCase {
    final class FakeKeychainStore: KeychainStoring {
        var copyStatus: OSStatus = errSecItemNotFound
        var updateStatus: OSStatus = errSecItemNotFound
        var addStatus: OSStatus = errSecSuccess
        var storedData: Data?

        func copyMatching(_ query: CFDictionary, result: UnsafeMutablePointer<AnyObject?>?) -> OSStatus {
            if copyStatus == errSecSuccess, let storedData {
                result?.pointee = storedData as AnyObject
            }
            return copyStatus
        }

        func update(_ query: CFDictionary, attributes: CFDictionary) -> OSStatus {
            if updateStatus == errSecSuccess {
                storedData = (attributes as NSDictionary)[kSecValueData] as? Data
            }
            return updateStatus
        }

        func add(_ query: CFDictionary) -> OSStatus {
            if addStatus == errSecSuccess {
                storedData = (query as NSDictionary)[kSecValueData] as? Data
            }
            return addStatus
        }
    }

    func testSharedInstanceExists() {
        // Test that the shared instance is accessible
        let sdk = MinFraudDevice.shared
        XCTAssertNotNil(sdk)
    }

    func testVersionIsValid() {
        // Test that version string is not empty
        XCTAssertFalse(MinFraudDevice.version.isEmpty)
        XCTAssertEqual(MinFraudDevice.version, "1.0.0")
    }

    func testDeviceIdFormat() {
        // Test that device ID, if available, is in UUID format
        let sdk = MinFraudDevice.shared
        if let deviceId = sdk.deviceID {
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
        let id1 = sdk.deviceID
        let id2 = sdk.deviceID

        if let id1 = id1, let id2 = id2 {
            XCTAssertEqual(id1, id2, "Device ID should remain consistent across calls")
        }
    }

    func testDeviceIdStoresInKeychainWhenMissing() {
        let fakeKeychain = FakeKeychainStore()
        fakeKeychain.updateStatus = errSecItemNotFound
        fakeKeychain.addStatus = errSecSuccess

        let deviceIdentifier = DeviceIdentifier(keychain: fakeKeychain)
        guard let deviceId = deviceIdentifier.deviceID else {
            return
        }

        let storedId = fakeKeychain.storedData.flatMap { String(data: $0, encoding: .utf8) }
        XCTAssertEqual(storedId, deviceId, "Device ID should be stored in keychain when missing")
    }

    func testDeviceIdUpdatesKeychainWhenPresent() {
        let fakeKeychain = FakeKeychainStore()
        fakeKeychain.updateStatus = errSecSuccess

        let deviceIdentifier = DeviceIdentifier(keychain: fakeKeychain)
        guard let deviceId = deviceIdentifier.deviceID else {
            return
        }

        let storedId = fakeKeychain.storedData.flatMap { String(data: $0, encoding: .utf8) }
        XCTAssertEqual(storedId, deviceId, "Device ID should be updated in keychain when present")
    }

    func testDeviceCheckSupportedCheck() {
        // Test that DeviceCheck support check doesn't crash
        let sdk = MinFraudDevice.shared
        let isSupported = sdk.isDeviceCheckSupported
        // DeviceCheck may or may not be supported depending on device/simulator
        // Just verify the call completes without error
        XCTAssertNotNil(isSupported)
    }

    func testDeviceCheckTokenGeneration() async {
        let sdk = MinFraudDevice.shared

        // Only test token generation if DeviceCheck is supported
        guard sdk.isDeviceCheckSupported else {
            // Skip test on unsupported devices (e.g., simulators)
            return
        }

        do {
            let token = try await sdk.generateDeviceCheckToken()
            XCTAssertFalse(token.isEmpty, "Token should not be empty")
        } catch let error as MinFraudDevice.DeviceCheckError {
            // Token generation can fail for various reasons
            // Just verify we got a proper error
            XCTAssertNotNil(error.errorDescription)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testDeviceCheckTokenStringGeneration() async {
        let sdk = MinFraudDevice.shared

        // Only test if DeviceCheck is supported
        guard sdk.isDeviceCheckSupported else {
            return
        }

        do {
            let tokenString = try await sdk.generateDeviceCheckTokenString()
            XCTAssertFalse(tokenString.isEmpty, "Token string should not be empty")
            // Verify it's valid base64
            XCTAssertNotNil(Data(base64Encoded: tokenString), "Token should be valid base64")
        } catch let error as MinFraudDevice.DeviceCheckError {
            XCTAssertNotNil(error.errorDescription)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
