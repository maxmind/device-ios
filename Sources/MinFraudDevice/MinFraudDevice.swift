import Foundation

public final class MinFraudDevice {
    public static let shared = MinFraudDevice()

    public var deviceID: String? {
        deviceIdentifier.getDeviceIdentifier()
    }

    private let deviceIdentifier = DeviceIdentifier()
    private let deviceCheckManager = DeviceCheckManager()

    private init() {}

    public var version: String {
        return "1.0.0"
    }

    public func isDeviceCheckSupported() -> Bool {
        return deviceCheckManager.isSupported
    }

    public func generateDeviceCheckToken() async -> Result<Data, DeviceCheckError> {
        return await deviceCheckManager.generateToken()
    }

    public func generateDeviceCheckTokenString() async -> Result<String, DeviceCheckError> {
        return await deviceCheckManager.generateTokenString()
    }
}
