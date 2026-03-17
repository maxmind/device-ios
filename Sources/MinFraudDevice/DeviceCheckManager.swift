import Foundation
import DeviceCheck

class DeviceCheckManager {
    public var isSupported: Bool {
        DCDevice.current.isSupported
    }

    /// Completion handler for DeviceCheck token generation
    typealias TokenCompletion = (Result<Data, DeviceCheckError>) -> Void

    /// Generates a DeviceCheck token for server-side validation.
    ///
    /// This token should be immediately sent to your backend server, which can then
    /// use Apple's DeviceCheck API to query or update the device's fraud state.
    ///
    /// Tokens are short-lived and should not be cached or reused.
    ///
    /// - Returns: A Result containing either the token Data or a DeviceCheckError
    func generateToken() async -> Result<Data, DeviceCheckError> {
        guard isSupported else {
            return .failure(.notSupported)
        }

        return await withCheckedContinuation { continuation in
            DCDevice.current.generateToken { token, error in
                if let token = token {
                    continuation.resume(returning: .success(token))
                } else if let error = error {
                    continuation.resume(returning: .failure(.tokenGenerationFailed(error)))
                } else {
                    continuation.resume(returning: .failure(.unknown))
                }
            }
        }
    }

    /// Convenience method to generate a base64-encoded token string.
    ///
    /// This format is useful for transmitting the token to your server over HTTP.
    ///
    /// - Returns: A Result containing either the base64-encoded token string or a DeviceCheckError
    func generateTokenString() async -> Result<String, DeviceCheckError> {
        let result = await generateToken()
        return result.map { $0.base64EncodedString() }
    }
}

/// Errors that can occur during DeviceCheck operations.
public enum DeviceCheckError: Error, LocalizedError {
    /// DeviceCheck is not supported on this device
    case notSupported

    /// Token generation failed
    case tokenGenerationFailed(Error)

    /// Unknown error occurred
    case unknown

    public var errorDescription: String? {
        switch self {
        case .notSupported:
            return "DeviceCheck is not supported on this device"
        case .tokenGenerationFailed(let error):
            return "Failed to generate DeviceCheck token: \(error.localizedDescription)"
        case .unknown:
            return "An unknown DeviceCheck error occurred"
        }
    }
}
