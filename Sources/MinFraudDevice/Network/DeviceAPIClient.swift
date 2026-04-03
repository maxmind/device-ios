import Foundation
import os

struct RequestBody: Encodable {
    let accountID: Int
    let deviceData: DeviceData

    enum CodingKeys: String, CodingKey {
        case accountID = "account_id"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accountID, forKey: .accountID)
        try deviceData.encode(to: encoder)
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

extension APIError: CustomNSError {
    public static var errorDomain: String { "\(SDKConfig.identifier).api" }

    public var errorCode: Int {
        switch self {
        case .serverError(let statusCode, _): return statusCode
        }
    }

    public var errorUserInfo: [String: Any] {
        switch self {
        case .serverError(_, let message):
            return [NSLocalizedDescriptionKey: errorDescription ?? message]
        }
    }
}

final class DeviceAPIClient: Sendable {
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
                storedID: deviceData.storedID,
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

    private func sendToURL(_ deviceData: DeviceData, url: URL) async throws -> ServerResponse {
        let body = RequestBody(accountID: config.accountID, deviceData: deviceData)
        let encoder = JSONEncoder()
        let bodyData = try encoder.encode(body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("minfraud-device-ios/\(SDKConfig.version)", forHTTPHeaderField: "User-Agent")
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
