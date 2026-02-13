import Foundation
import os

struct RequestBody: Encodable {
    let accountID: Int
    let idfv: String
    let trackingToken: String?
    let requestDurationMS: Int?

    enum CodingKeys: String, CodingKey {
        case accountID = "account_id"
        case idfv
        case trackingToken = "tracking_token"
        case requestDurationMS = "request_duration"
    }

    init(accountID: Int, deviceData: DeviceData) {
        self.accountID = accountID
        self.idfv = deviceData.idfv
        self.trackingToken = deviceData.trackingToken
        self.requestDurationMS = deviceData.requestDurationMS
    }
}

/// Errors from the MinFraud Device API.
public enum APIError: Error, LocalizedError {
    /// The server returned a non-success HTTP status code.
    case serverError(statusCode: Int, message: String)

    public var errorDescription: String? {
        switch self {
        case .serverError(let statusCode, let message):
            return "Server returned \(statusCode): \(message)"
        }
    }
}

final class DeviceAPIClient {
    private let config: SDKConfig
    private let session: URLSession
    private let logger: Logger?

    init(config: SDKConfig, session: URLSession = .shared, logger: Logger? = nil) {
        self.config = config
        self.session = session
        self.logger = logger
    }

    func sendDeviceData(_ deviceData: DeviceData) async throws -> ServerResponse {
        if let serverURL = config.serverURL {
            let url = serverURL.appendingPathComponent(SDKConfig.endpointPath)
            return try await sendToURL(deviceData, url: url)
        } else {
            return try await sendWithDualRequest(deviceData)
        }
    }

    private func sendWithDualRequest(_ deviceData: DeviceData) async throws -> ServerResponse {
        let ipv6URL = URL(string: "https://\(SDKConfig.defaultIPv6Host)\(SDKConfig.endpointPath)")!

        // Use a monotonic approach for calculating request duration.
        let startTime = ProcessInfo.processInfo.systemUptime
        let ipv6Response = try await sendToURL(deviceData, url: ipv6URL)
        let requestDurationMS = Int((ProcessInfo.processInfo.systemUptime - startTime) * 1000)

        if ipv6Response.ipVersion == 6 {
            let ipv4URL = URL(string: "https://\(SDKConfig.defaultIPv4Host)\(SDKConfig.endpointPath)")!
            let dataWithDuration = DeviceData(
                idfv: deviceData.idfv,
                trackingToken: deviceData.trackingToken,
                requestDurationMS: requestDurationMS
            )
            do {
                _ = try await sendToURL(dataWithDuration, url: ipv4URL)
                logger?.debug("IPv4 device data sent successfully")
            } catch {
                logger?.debug("IPv4 device data send failed (non-fatal): \(error.localizedDescription)")
            }
        }

        return ipv6Response
    }

    func sendToURL(_ deviceData: DeviceData, url: URL) async throws -> ServerResponse {
        let body = RequestBody(accountID: config.accountID, deviceData: deviceData)
        let encoder = JSONEncoder()
        let bodyData = try encoder.encode(body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("minfraud-device-ios/0.1.0", forHTTPHeaderField: "User-Agent")
        request.httpBody = bodyData

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError(statusCode: 0, message: "Invalid response")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: message)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(ServerResponse.self, from: data)
    }
}
