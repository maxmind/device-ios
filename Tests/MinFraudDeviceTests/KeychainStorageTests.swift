import XCTest
@testable import MinFraudDevice

final class KeychainStorageTests: XCTestCase {

    func testMockGetReturnsNilForMissingKey() {
        let storage = MockKeychainStorage()
        XCTAssertNil(storage.get(forKey: "nonexistent"))
    }

    func testMockSetAndGet() {
        let storage = MockKeychainStorage()
        let success = storage.set("value1", forKey: "key1")

        XCTAssertTrue(success)
        XCTAssertEqual(storage.get(forKey: "key1"), "value1")
    }

    func testMockSetOverwritesExisting() {
        let storage = MockKeychainStorage()
        _ = storage.set("old", forKey: "key")
        _ = storage.set("new", forKey: "key")

        XCTAssertEqual(storage.get(forKey: "key"), "new")
    }

    func testMockMultipleKeys() {
        let storage = MockKeychainStorage()
        _ = storage.set("val1", forKey: "key1")
        _ = storage.set("val2", forKey: "key2")

        XCTAssertEqual(storage.get(forKey: "key1"), "val1")
        XCTAssertEqual(storage.get(forKey: "key2"), "val2")
    }

    func testMockSetFailure() {
        let storage = MockKeychainStorage()
        storage.shouldFailOnSet = true

        let success = storage.set("value", forKey: "key")

        XCTAssertFalse(success)
        XCTAssertNil(storage.get(forKey: "key"))
    }

    func testMockReset() {
        let storage = MockKeychainStorage()
        _ = storage.set("value", forKey: "key")
        storage.reset()

        XCTAssertNil(storage.get(forKey: "key"))
    }
}
