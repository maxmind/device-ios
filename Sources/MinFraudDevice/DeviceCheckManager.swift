import Foundation
import DeviceCheck

final class DeviceCheckManager {
    typealias DeviceCheckError = MinFraudDevice.DeviceCheckError

    var isSupported: Bool {
        DCDevice.current.isSupported
    }

    /// Generates a DeviceCheck token for server-side validation.
    ///
    /// This token should be immediately sent to your backend server, which can then
    /// use Apple's DeviceCheck API to query or update the device's fraud state.
    ///
    /// Tokens are short-lived and should not be cached or reused.
    ///
    /// - Throws: `DeviceCheckError` if DeviceCheck is unsupported or token generation fails.
    func generateToken() async throws -> Data {
        guard isSupported else {
            throw DeviceCheckError.notSupported
        }

        return try await withCheckedThrowingContinuation { continuation in
            DCDevice.current.generateToken { token, error in
                if let token = token {
                    continuation.resume(returning: token)
                } else if let error = error {
                    continuation.resume(throwing: DeviceCheckError.tokenGenerationFailed(error))
                } else {
                    continuation.resume(throwing: DeviceCheckError.unknown)
                }
            }
        }
    }

    /// Convenience method to generate a base64-encoded token string.
    ///
    /// This format is useful for transmitting the token to your server over HTTP.
    ///
    /// - Throws: `DeviceCheckError` if token generation fails.
    func generateTokenString() async throws -> String {
        let token = try await generateToken()
        return token.base64EncodedString()
    }
}
