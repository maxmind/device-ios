import XCTest
@testable import MinFraudDevice

final class ModelTests: XCTestCase {

    func testDeviceDataEncoding() throws {
        struct Case {
            let label: String
            let trackingToken: String?
            let requestDurationMS: Int?
            let expectedToken: String?
            let expectedDuration: Int?
        }

        let cases: [Case] = [
            Case(label: "all fields", trackingToken: "abc123:hmac456",
                 requestDurationMS: 42, expectedToken: "abc123:hmac456", expectedDuration: 42),
            Case(label: "nil fields omitted", trackingToken: nil,
                 requestDurationMS: nil, expectedToken: nil, expectedDuration: nil)
        ]

        for tc in cases {
            let data = DeviceData(
                idfv: "test-idfv",
                trackingToken: tc.trackingToken,
                requestDurationMS: tc.requestDurationMS
            )
            let encoded = try JSONEncoder().encode(data)
            let json = try XCTUnwrap(
                JSONSerialization.jsonObject(with: encoded) as? [String: Any],
                "Failed to decode JSON for case: \(tc.label)"
            )

            XCTAssertEqual(json["idfv"] as? String, "test-idfv", "Failed for case: \(tc.label)")
            XCTAssertEqual(json["tracking_token"] as? String, tc.expectedToken, "Failed for case: \(tc.label)")
            XCTAssertEqual(json["request_duration"] as? Int, tc.expectedDuration, "Failed for case: \(tc.label)")
        }
    }

    func testServerResponseDecoding() throws {
        struct Case {
            let label: String
            let json: String
            let expectedToken: String?
            let expectedIPVersion: Int?
        }

        let cases: [Case] = [
            Case(label: "valid values",
                 json: "{\"tracking_token\":\"abc123:hmac456\",\"ip_version\":6}",
                 expectedToken: "abc123:hmac456", expectedIPVersion: 6),
            Case(label: "null values",
                 json: "{\"tracking_token\":null,\"ip_version\":null}",
                 expectedToken: nil, expectedIPVersion: nil),
            Case(label: "missing values",
                 json: "{}",
                 expectedToken: nil, expectedIPVersion: nil),
            Case(label: "unknown fields ignored",
                 json: "{\"tracking_token\":\"abc123:hmac456\",\"ip_version\":6,\"unknown\":\"value\"}",
                 expectedToken: "abc123:hmac456", expectedIPVersion: 6)
        ]

        for tc in cases {
            let response = try JSONDecoder().decode(ServerResponse.self, from: Data(tc.json.utf8))

            XCTAssertEqual(response.trackingToken, tc.expectedToken, "Failed for case: \(tc.label)")
            XCTAssertEqual(response.ipVersion, tc.expectedIPVersion, "Failed for case: \(tc.label)")
        }
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
