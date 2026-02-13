import Foundation
import DeviceCheck

/// Manages DeviceCheck integration for fraud state management.
///
/// DeviceCheck provides Apple's framework for tracking fraud-related device state
/// on Apple's servers. This is the recommended approach for persisting fraud signals
/// that survive factory resets and device transfers.
///
/// ## Server-Side Integration Required
///
/// DeviceCheck tokens must be validated and state managed through your backend server
/// using Apple's DeviceCheck API. The tokens generated here are short-lived and must
/// be immediately sent to your server.
class DeviceCheckManager {

    // MARK: - Properties

    /// Completion handler for DeviceCheck token generation
    typealias TokenCompletion = (Result<Data, DeviceCheckError>) -> Void

    // MARK: - Public Methods

    /// Checks if DeviceCheck is supported on the current device.
    ///
    /// DeviceCheck is available on iOS 11+ but may not be supported on all devices
    /// (e.g., simulators, certain device configurations).
    ///
    /// - Returns: true if DeviceCheck is supported, false otherwise
    func isSupported() -> Bool {
        return DCDevice.current.isSupported
    }

    /// Generates a DeviceCheck token for server-side validation.
    ///
    /// This token should be immediately sent to your backend server, which can then
    /// use Apple's DeviceCheck API to query or update the device's fraud state.
    ///
    /// Tokens are short-lived and should not be cached or reused.
    ///
    /// - Returns: A Result containing either the token Data or a DeviceCheckError
    func generateToken() async -> Result<Data, DeviceCheckError> {
        guard isSupported() else {
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

// MARK: - DeviceCheck Errors

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
