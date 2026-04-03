import XCTest
@testable import MinFraudDevice

final class DeviceDataCollectorTests: XCTestCase {

    func testCollectUsesSystemIDFVWhenKeychainEmpty() throws {
        let storage = MockKeychainStorage()
        let collector = DeviceDataCollector(
            storage: storage,
            idfvProvider: { "SYSTEM-IDFV-123" }
        )

        let data = try collector.collect()

        XCTAssertEqual(data.idfv, "SYSTEM-IDFV-123")
    }

    func testCollectCachesIDFVInKeychain() throws {
        let storage = MockKeychainStorage()
        let collector = DeviceDataCollector(
            storage: storage,
            idfvProvider: { "SYSTEM-IDFV-123" }
        )

        _ = try collector.collect()

        XCTAssertEqual(storage.get(forKey: KeychainStorage.idfvKey), "SYSTEM-IDFV-123")
    }

    func testCollectUsesKeychainIDFVWhenAvailable() throws {
        let storage = MockKeychainStorage()
        _ = storage.set("CACHED-IDFV", forKey: KeychainStorage.idfvKey)
        var providerCalled = false
        let collector = DeviceDataCollector(
            storage: storage,
            idfvProvider: {
                providerCalled = true
                return "SYSTEM-IDFV"
            }
        )

        let data = try collector.collect()

        XCTAssertEqual(data.idfv, "CACHED-IDFV")
        XCTAssertFalse(providerCalled)
    }

    func testCollectThrowsWhenIDFVUnavailable() {
        let storage = MockKeychainStorage()
        let collector = DeviceDataCollector(
            storage: storage,
            idfvProvider: { nil }
        )

        XCTAssertThrowsError(try collector.collect()) { error in
            XCTAssertTrue(error is MinFraudDeviceError)
            if let deviceError = error as? MinFraudDeviceError {
                XCTAssertEqual(deviceError, .idfvUnavailable)
            }
        }
    }

    func testCollectIncludesStoredIDFromKeychain() throws {
        let storage = MockKeychainStorage()
        _ = storage.set("existing-stored-id", forKey: KeychainStorage.storedIDKey)
        let collector = DeviceDataCollector(
            storage: storage,
            idfvProvider: { "IDFV" }
        )

        let data = try collector.collect()

        XCTAssertEqual(data.storedID, "existing-stored-id")
    }

    func testCollectReturnsNilStoredIDWhenNotStored() throws {
        let storage = MockKeychainStorage()
        let collector = DeviceDataCollector(
            storage: storage,
            idfvProvider: { "IDFV" }
        )

        let data = try collector.collect()

        XCTAssertNil(data.storedID)
    }

    func testCollectReturnsNilRequestDuration() throws {
        let storage = MockKeychainStorage()
        let collector = DeviceDataCollector(
            storage: storage,
            idfvProvider: { "IDFV" }
        )

        let data = try collector.collect()

        XCTAssertNil(data.requestDurationMS)
    }

    func testCollectConsistentIDFVAcrossCalls() throws {
        let storage = MockKeychainStorage()
        var callCount = 0
        let collector = DeviceDataCollector(
            storage: storage,
            idfvProvider: {
                callCount += 1
                return "IDFV-\(callCount)"
            }
        )

        let first = try collector.collect()
        let second = try collector.collect()

        XCTAssertEqual(first.idfv, second.idfv)
    }
}
