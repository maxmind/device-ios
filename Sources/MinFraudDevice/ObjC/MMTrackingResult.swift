import Foundation

/// Objective-C compatible result of a device tracking operation.
///
/// This class wraps ``TrackingResult`` for use from Objective-C code.
/// Swift callers should use ``TrackingResult`` directly.
@objc(MMTrackingResult)
public final class ObjCTrackingResult: NSObject {
    /// Opaque tracking token to pass to the minFraud API.
    @objc public let trackingToken: String

    init(result: TrackingResult) {
        self.trackingToken = result.trackingToken
    }

    public override var description: String {
        "MMTrackingResult(trackingToken: <redacted>)"
    }
}
