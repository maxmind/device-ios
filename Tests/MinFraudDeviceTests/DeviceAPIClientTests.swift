import XCTest
@testable import MinFraudDevice

final class DeviceAPIClientTests: XCTestCase {
    private var mockSession: URLSession?

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: config)
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        mockSession = nil
        super.tearDown()
    }

    private var testDeviceData: DeviceData {
        DeviceData(idfv: "test-idfv", trackingToken: "test-token", requestDurationMS: nil)
    }

    private func makeClient(
        accountID: Int = 99999,
        serverURL: URL? = URL(string: "https://test.maxmind.com")
    ) -> DeviceAPIClient {
        let config = SDKConfig(accountID: accountID, serverURL: serverURL)
        return DeviceAPIClient(config: config, session: mockSession ?? .shared)
    }

    func testSendDeviceDataSuccessResponses() async throws {
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
            Case(label: "empty object",
                 json: "{}",
                 expectedToken: nil, expectedIPVersion: nil)
        ]

        for tc in cases {
            MockURLProtocol.requestHandler = { _ in
                let response = HTTPURLResponse(
                    url: URL(string: "https://test.maxmind.com")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/json"]
                )!
                return (response, Data(tc.json.utf8))
            }

            let client = makeClient()
            let response = try await client.sendDeviceData(testDeviceData)

            XCTAssertEqual(response.trackingToken, tc.expectedToken, "Failed for case: \(tc.label)")
            XCTAssertEqual(response.ipVersion, tc.expectedIPVersion, "Failed for case: \(tc.label)")
        }
    }

    func testSendDeviceDataErrorResponses() async {
        let cases: [(label: String, statusCode: Int)] = [
            ("server error", 500),
            ("client error", 400)
        ]

        for (label, statusCode) in cases {
            MockURLProtocol.requestHandler = { _ in
                let response = HTTPURLResponse(
                    url: URL(string: "https://test.maxmind.com")!,
                    statusCode: statusCode,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (response, Data("{}".utf8))
            }

            let client = makeClient()
            do {
                _ = try await client.sendDeviceData(testDeviceData)
                XCTFail("Expected error to be thrown for case: \(label)")
            } catch let error as APIError {
                if case .serverError(let code, _) = error {
                    XCTAssertEqual(code, statusCode, "Failed for case: \(label)")
                } else {
                    XCTFail("Expected serverError for case: \(label)")
                }
            } catch {
                XCTFail("Unexpected error type for case \(label): \(error)")
            }
        }
    }

    func testSendDeviceDataRequest() async throws {
        var capturedBody: [String: Any]?
        var capturedURL: URL?
        var capturedContentType: String?
        MockURLProtocol.requestHandler = { request in
            if let bodyData = request.httpBody ?? request.httpBodyStream?.readAll() {
                capturedBody = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any]
            }
            capturedContentType = request.value(forHTTPHeaderField: "Content-Type")
            capturedURL = request.url
            let data = Data("""
            {"tracking_token":"abc123:hmac456","ip_version":4}
            """.utf8)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, data)
        }

        let client = makeClient(accountID: 12345, serverURL: URL(string: "https://api.example.com")!)
        _ = try await client.sendDeviceData(testDeviceData)

        XCTAssertEqual(capturedURL?.absoluteString, "https://api.example.com/device/ios")
        XCTAssertEqual(capturedContentType, "application/json")
        XCTAssertNotNil(capturedBody)
        XCTAssertEqual(capturedBody?["account_id"] as? Int, 12345)
        XCTAssertEqual(capturedBody?["idfv"] as? String, "test-idfv")
        XCTAssertEqual(capturedBody?["tracking_token"] as? String, "test-token")
    }

    func testRequestBodyEncodesDeviceDataFieldsFlat() throws {
        let deviceData = DeviceData(idfv: "test-idfv", trackingToken: "test-token", requestDurationMS: 42)
        let body = RequestBody(accountID: 123, deviceData: deviceData)
        let data = try JSONEncoder().encode(body)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(json["account_id"] as? Int, 123)
        XCTAssertEqual(json["idfv"] as? String, "test-idfv")
        XCTAssertEqual(json["tracking_token"] as? String, "test-token")
        XCTAssertEqual(json["request_duration"] as? Int, 42)
        XCTAssertNil(json["deviceData"], "DeviceData fields should be flat, not nested")
    }

    // MARK: - Dual Request Tests

    func testDualRequestSendsToIPv6AndIPv4Endpoints() async throws {
        var capturedURLs: [String] = []
        var requestCount = 0
        MockURLProtocol.requestHandler = { request in
            requestCount += 1
            capturedURLs.append(request.url?.absoluteString ?? "")
            let body: String
            if requestCount == 1 {
                body = """
                {"tracking_token":"abc123:hmac456","ip_version":6}
                """
            } else {
                body = """
                {"tracking_token":"abc123:hmac456","ip_version":4}
                """
            }
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data(body.utf8))
        }

        let client = makeClient(serverURL: nil)
        _ = try await client.sendDeviceData(testDeviceData)

        XCTAssertEqual(capturedURLs.count, 2)
        XCTAssertTrue(capturedURLs[0].contains("d-ipv6.mmapiws.com"))
        XCTAssertTrue(capturedURLs[1].contains("d-ipv4.mmapiws.com"))
    }

    func testDualRequestIncludesRequestDurationOnIPv4Only() async throws {
        var capturedBodies: [[String: Any]] = []
        var requestCount = 0
        MockURLProtocol.requestHandler = { request in
            requestCount += 1
            if let bodyData = request.httpBody ?? request.httpBodyStream?.readAll(),
               let json = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any] {
                capturedBodies.append(json)
            }
            let body: String
            if requestCount == 1 {
                body = """
                {"tracking_token":"abc123:hmac456","ip_version":6}
                """
            } else {
                body = """
                {"tracking_token":"abc123:hmac456","ip_version":4}
                """
            }
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data(body.utf8))
        }

        let client = makeClient(serverURL: nil)
        _ = try await client.sendDeviceData(testDeviceData)

        XCTAssertEqual(capturedBodies.count, 2)
        XCTAssertNil(capturedBodies[0]["request_duration"])
        XCTAssertNotNil(capturedBodies[1]["request_duration"])
        if let duration = capturedBodies[1]["request_duration"] as? Int {
            XCTAssertGreaterThanOrEqual(duration, 0)
        }
    }

    func testDualRequestSkipsIPv4WhenIPVersionIsNot6() async throws {
        var requestCount = 0
        MockURLProtocol.requestHandler = { request in
            requestCount += 1
            let data = Data("""
            {"tracking_token":"abc123:hmac456","ip_version":4}
            """.utf8)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, data)
        }

        let client = makeClient(serverURL: nil)
        _ = try await client.sendDeviceData(testDeviceData)

        XCTAssertEqual(requestCount, 1)
    }

    func testDualRequestIPv4FailureIsNonFatal() async throws {
        var requestCount = 0
        MockURLProtocol.requestHandler = { request in
            requestCount += 1
            if requestCount == 1 {
                let data = Data("""
                {"tracking_token":"abc123:hmac456","ip_version":6}
                """.utf8)
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/json"]
                )!
                return (response, data)
            } else {
                let data = Data("""
                {"error":"Server Error"}
                """.utf8)
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 500,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (response, data)
            }
        }

        let client = makeClient(serverURL: nil)
        let response = try await client.sendDeviceData(testDeviceData)

        XCTAssertEqual(response.trackingToken, "abc123:hmac456")
        XCTAssertEqual(requestCount, 2)
    }
}

private extension InputStream {
    func readAll() -> Data {
        open()
        defer { close() }
        var data = Data()
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
        defer { buffer.deallocate() }
        while hasBytesAvailable {
            let count = read(buffer, maxLength: 1024)
            if count <= 0 { break }
            data.append(buffer, count: count)
        }
        return data
    }
}
