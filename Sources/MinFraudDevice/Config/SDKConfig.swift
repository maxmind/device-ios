import Foundation

/// Configuration for the MinFraud Device SDK.
public struct SDKConfig: Sendable {
    /// Your MaxMind account ID.
    public let accountID: Int

    /// Custom server URL. When `nil`, the SDK uses the default dual-stack servers.
    public let serverURL: URL?

    /// Whether to enable logging via `os.Logger`.
    public let loggingEnabled: Bool

    /// Automatic collection interval in seconds. Set to `0` to disable,
    /// or a value of `300` or greater to enable periodic collection.
    public let collectionIntervalSeconds: Int

    /// Creates a new SDK configuration.
    ///
    /// - Parameters:
    ///   - accountID: Your MaxMind account ID. Must be positive.
    ///   - serverURL: Custom server URL, or `nil` to use default servers.
    ///   - loggingEnabled: Whether to enable logging. Defaults to `false`.
    ///   - collectionIntervalSeconds: Automatic collection interval in seconds.
    ///     Must be `0` (disabled) or at least `300`. Defaults to `0`.
    public init(
        accountID: Int,
        serverURL: URL? = nil,
        loggingEnabled: Bool = false,
        collectionIntervalSeconds: Int = 0
    ) {
        precondition(accountID > 0, "Account ID must be positive")
        precondition(
            collectionIntervalSeconds == 0 || collectionIntervalSeconds >= 300,
            "Collection interval must be 0 (disabled) or at least 300 seconds"
        )
        self.accountID = accountID
        self.serverURL = serverURL
        self.loggingEnabled = loggingEnabled
        self.collectionIntervalSeconds = collectionIntervalSeconds
    }

    static let version = "0.1.0"
    static let identifier = "com.maxmind.minfraud.device"
    static let defaultIPv6Host = "d-ipv6.mmapiws.com"
    static let defaultIPv4Host = "d-ipv4.mmapiws.com"
    static let endpointPath = "/device/ios"
}
