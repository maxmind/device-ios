import Foundation

public final class MinFraudDevice {
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

    public static let shared = MinFraudDevice()

    public static let version = "1.0.0"

    private let deviceIdentifier = DeviceIdentifier()
    private let deviceCheckManager = DeviceCheckManager()

    private init() {}

    public var deviceID: String? {
        deviceIdentifier.deviceID
    }

    public var isDeviceCheckSupported: Bool {
        deviceCheckManager.isSupported
    }

    public func generateDeviceCheckToken() async throws -> Data {
        try await deviceCheckManager.generateToken()
    }

    public func generateDeviceCheckTokenString() async throws -> String {
        try await deviceCheckManager.generateTokenString()
    }
}
