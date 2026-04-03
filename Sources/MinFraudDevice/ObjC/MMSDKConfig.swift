import Foundation

/// Objective-C compatible configuration for the MinFraud Device SDK.
///
/// This class wraps ``SDKConfig`` for use from Objective-C code.
/// Swift callers should use ``SDKConfig`` directly.
@objc(MMSDKConfig)
public final class ObjCSDKConfig: NSObject {
    let config: SDKConfig

    /// Creates a new SDK configuration with all options.
    ///
    /// - Parameters:
    ///   - accountID: Your MaxMind account ID. Must be positive.
    ///   - serverURL: Custom server URL, or `nil` to use default servers.
    ///   - loggingEnabled: Whether to enable logging.
    ///   - collectionIntervalSeconds: Automatic collection interval in seconds.
    ///     Must be `0` (disabled) or at least `300`.
    @objc
    public init(
        accountID: Int,
        serverURL: URL?,
        loggingEnabled: Bool,
        collectionIntervalSeconds: Int
    ) {
        self.config = SDKConfig(
            accountID: accountID,
            serverURL: serverURL,
            loggingEnabled: loggingEnabled,
            collectionIntervalSeconds: collectionIntervalSeconds
        )
    }

    /// Creates a new SDK configuration with default options.
    ///
    /// - Parameter accountID: Your MaxMind account ID. Must be positive.
    @objc
    public convenience init(accountID: Int) {
        self.init(
            accountID: accountID,
            serverURL: nil,
            loggingEnabled: false,
            collectionIntervalSeconds: 0
        )
    }
}
