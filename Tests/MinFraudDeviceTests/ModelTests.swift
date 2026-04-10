import XCTest
@testable import MinFraudDevice

final class ModelTests: XCTestCase {

    func testDeviceDataEncoding() throws {
        struct Case {
            let label: String
            let storedID: String?
            let requestDurationMS: Int?
            let expectedStoredID: String?
            let expectedDuration: Int?
        }

        let cases: [Case] = [
            Case(label: "all fields", storedID: "abc123:hmac456",
                 requestDurationMS: 42, expectedStoredID: "abc123:hmac456", expectedDuration: 42),
            Case(label: "nil fields omitted", storedID: nil,
                 requestDurationMS: nil, expectedStoredID: nil, expectedDuration: nil)
        ]

        for tc in cases {
            let data = DeviceData(
                idfv: "test-idfv",
                storedID: tc.storedID,
                requestDurationMS: tc.requestDurationMS
            )
            let encoded = try JSONEncoder().encode(data)
            let json = try XCTUnwrap(
                JSONSerialization.jsonObject(with: encoded) as? [String: Any],
                "Failed to decode JSON for case: \(tc.label)"
            )

            XCTAssertEqual(json["idfv"] as? String, "test-idfv", "Failed for case: \(tc.label)")
            XCTAssertEqual(json["stored_id"] as? String, tc.expectedStoredID, "Failed for case: \(tc.label)")
            XCTAssertEqual(json["request_duration"] as? Int, tc.expectedDuration, "Failed for case: \(tc.label)")
        }
    }

    func testServerResponseDecoding() throws {
        let json = "{\"stored_id\":\"abc123:hmac456\",\"ip_version\":6}"
        let response = try JSONDecoder().decode(ServerResponse.self, from: Data(json.utf8))

        XCTAssertEqual(response.storedID, "abc123:hmac456")
        XCTAssertEqual(response.ipVersion, 6)
    }

    func testServerResponseIgnoresUnknownFields() throws {
        let json = "{\"stored_id\":\"abc123:hmac456\",\"ip_version\":6,\"unknown\":\"value\"}"
        let response = try JSONDecoder().decode(ServerResponse.self, from: Data(json.utf8))

        XCTAssertEqual(response.storedID, "abc123:hmac456")
        XCTAssertEqual(response.ipVersion, 6)
    }

    func testServerResponseRejectsMissingStoredID() {
        let json = "{\"ip_version\":6}"
        XCTAssertThrowsError(try JSONDecoder().decode(ServerResponse.self, from: Data(json.utf8)))
    }

    func testServerResponseRejectsNullStoredID() {
        let json = "{\"stored_id\":null,\"ip_version\":6}"
        XCTAssertThrowsError(try JSONDecoder().decode(ServerResponse.self, from: Data(json.utf8)))
    }

    func testServerResponseRejectsBlankStoredID() {
        let json = "{\"stored_id\":\"   \",\"ip_version\":6}"
        XCTAssertThrowsError(try JSONDecoder().decode(ServerResponse.self, from: Data(json.utf8)))
    }

    func testServerResponseRejectsMissingIPVersion() {
        let json = "{\"stored_id\":\"abc123:hmac456\"}"
        XCTAssertThrowsError(try JSONDecoder().decode(ServerResponse.self, from: Data(json.utf8)))
    }

    func testServerResponseRejectsInvalidIPVersion() {
        let json = "{\"stored_id\":\"abc123:hmac456\",\"ip_version\":5}"
        XCTAssertThrowsError(try JSONDecoder().decode(ServerResponse.self, from: Data(json.utf8)))
    }

    func testServerResponseRejectsEmptyObject() {
        let json = "{}"
        XCTAssertThrowsError(try JSONDecoder().decode(ServerResponse.self, from: Data(json.utf8)))
    }

    func testTrackingResultStoresToken() {
        let result = TrackingResult(trackingToken: "abc123:hmac456")
        XCTAssertEqual(result.trackingToken, "abc123:hmac456", "raw token value is available")
        XCTAssertEqual(
            result.description,
            "TrackingResult(trackingToken: <redacted>)",
            "tracking token is redacted"
        )
    }
}
