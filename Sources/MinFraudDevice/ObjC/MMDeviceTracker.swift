import Foundation

/// Objective-C compatible entry point for the MinFraud Device SDK.
///
/// This class wraps ``DeviceTracker`` for use from Objective-C code.
/// Swift callers should use ``DeviceTracker`` directly.
@objc(MMDeviceTracker)
public final class ObjCDeviceTracker: NSObject {
    private let tracker: DeviceTracker

    /// Creates a new device tracker with the given configuration.
    ///
    /// - Parameter config: The SDK configuration.
    @objc
    public init(config: ObjCSDKConfig) {
        self.tracker = DeviceTracker(config: config.config)
    }

    /// Collects device data and sends it to MaxMind servers.
    ///
    /// On success, the completion handler receives an ``MMTrackingResult``
    /// containing the tracking token. On failure, it receives an `NSError`.
    ///
    /// - Parameter completion: Called on the main queue with the result or error.
    @objc
    public func collectAndSend(completion: @escaping (ObjCTrackingResult?, NSError?) -> Void) {
        Task { @MainActor in
            do {
                let result = try await tracker.collectAndSend()
                completion(ObjCTrackingResult(result: result), nil)
            } catch {
                completion(nil, error as NSError)
            }
        }
    }

    /// Cancels automatic collection and releases resources.
    @objc
    public func shutdown() {
        tracker.shutdown()
    }
}
