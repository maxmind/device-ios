import Foundation

/// The main SDK class for MaxMind minFraud device identification.
///
/// This SDK provides Apple-compliant device identification for fraud detection purposes.
/// It uses IDFV (Identifier for Vendor) with keychain persistence to maintain device
/// identity across app reinstalls while respecting Apple's privacy guidelines.
///
/// ## Usage
///
/// ```swift
/// import MinFraudDevice
///
/// // Get the shared instance
/// let sdk = MinFraudDevice.shared
///
/// // Retrieve the device identifier
/// if let deviceId = sdk.getDeviceId() {
///     print("Device ID: \(deviceId)")
/// }
/// ```
public class MinFraudDevice {

    // MARK: - Singleton

    /// The shared instance of the MinFraudDevice SDK.
    ///
    /// Using a shared instance ensures consistent device identification throughout
    /// your app's lifecycle.
    public static let shared = MinFraudDevice()

    // MARK: - Properties

    private let deviceIdentifier = DeviceIdentifier()
    private let deviceCheckManager = DeviceCheckManager()

    // MARK: - Initialization

    /// Private initializer to enforce singleton pattern.
    private init() {}

    // MARK: - Public Methods

    /// Retrieves the persistent device identifier.
    ///
    /// This identifier is based on the system's IDFV (Identifier for Vendor) and is
    /// persisted in the keychain to maintain consistency across app reinstalls.
    ///
    /// The identifier will remain the same for:
    /// - Multiple app launches
    /// - App updates
    /// - Device reboots
    /// - (In most cases) App reinstalls
    ///
    /// The identifier will change if:
    /// - The user uninstalls all apps from your vendor
    /// - The device is factory reset
    /// - The user restores from a backup made on a different device
    ///
    /// - Returns: A UUID string representing the device, or nil if the identifier cannot be determined
    public func getDeviceId() -> String? {
        return deviceIdentifier.getDeviceIdentifier()
    }

    /// Returns the SDK version.
    ///
    /// - Returns: The current version of the MinFraudDevice SDK
    public var version: String {
        return "1.0.0"
    }

    // MARK: - DeviceCheck Integration

    /// Checks if DeviceCheck is supported on the current device.
    ///
    /// DeviceCheck provides Apple's server-side fraud state management.
    /// It may not be available on simulators or certain device configurations.
    ///
    /// - Returns: true if DeviceCheck is supported, false otherwise
    public func isDeviceCheckSupported() -> Bool {
        return deviceCheckManager.isSupported()
    }

    /// Generates a DeviceCheck token for server-side fraud analysis.
    ///
    /// This token should be sent to your backend server, which can use Apple's
    /// DeviceCheck API to query or update fraud-related device state.
    ///
    /// **Important**: Tokens are short-lived and should be sent to your server immediately.
    /// Do not cache or reuse tokens.
    ///
    /// ## Server-Side Integration
    ///
    /// Your server should:
    /// 1. Receive this token from your app
    /// 2. Use Apple's DeviceCheck API to validate the token
    /// 3. Query or update two bits of fraud state per device
    /// 4. Return the fraud assessment to your app
    ///
    /// See Apple's DeviceCheck documentation for server API details.
    ///
    /// - Returns: A Result containing either the token Data or a DeviceCheckError
    public func generateDeviceCheckToken() async -> Result<Data, DeviceCheckError> {
        return await deviceCheckManager.generateToken()
    }

    /// Generates a base64-encoded DeviceCheck token string.
    ///
    /// This convenience method returns the token in a format suitable for
    /// transmitting to your server over HTTP.
    ///
    /// - Returns: A Result containing either the base64-encoded token string or a DeviceCheckError
    public func generateDeviceCheckTokenString() async -> Result<String, DeviceCheckError> {
        return await deviceCheckManager.generateTokenString()
    }
}
