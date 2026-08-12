import Foundation

/// Objective-C compatible entry point for the MinFraud Device SDK.
///
/// This class wraps ``DeviceTracker`` for use from Objective-C code.
/// Swift callers should use ``DeviceTracker`` directly.
@objc(MMDeviceTracker)
public final class ObjCDeviceTracker: NSObject {
    private let tracker: DeviceTracker
    private var isShutDown = false
    private let lock = NSLock()

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
    /// The completion handler is always called exactly once unless
    /// ``shutdown`` is called before the operation completes. The tracker
    /// is kept alive until the operation finishes, even if all other
    /// references are released.
    ///
    /// - Parameter completion: Called on the main queue with the result or error.
    @objc
    public func collectAndSend(completion: @escaping (ObjCTrackingResult?, NSError?) -> Void) {
        Task { @MainActor in
            do {
                let result = try await self.tracker.collectAndSend()
                guard !self.isShutDownValue() else { return }
                completion(ObjCTrackingResult(result: result), nil)
            } catch {
                guard !self.isShutDownValue() else { return }
                completion(nil, error as NSError)
            }
        }
    }

    /// Reads `isShutDown` under the lock.
    ///
    /// This is a separate synchronous method because `NSLock.lock()` and
    /// `unlock()` are unavailable from asynchronous contexts.
    private func isShutDownValue() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return isShutDown
    }

    /// Cancels automatic collection and releases resources.
    ///
    /// Any in-flight ``collectAndSend`` call will complete silently
    /// without invoking its completion handler.
    @objc
    public func shutdown() {
        lock.lock()
        defer { lock.unlock() }
        isShutDown = true
        tracker.shutdown()
    }
}
