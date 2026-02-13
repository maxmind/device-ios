import Foundation

/// The result of a device tracking operation.
///
/// Pass ``trackingToken`` to your backend for inclusion in the minFraud API
/// request's `/device/tracking_token` field. Do not parse this value or
/// rely on its format, which may change without notice.
///
/// The token is redacted in the `description` to avoid accidental logging.
public struct TrackingResult: Sendable, CustomStringConvertible {
    /// Opaque tracking token to pass to the minFraud API.
    public let trackingToken: String

    init(trackingToken: String) {
        precondition(!trackingToken.trimmingCharacters(in: .whitespaces).isEmpty, "Tracking token must not be blank")
        self.trackingToken = trackingToken
    }

    public var description: String {
        "TrackingResult(trackingToken: <redacted>)"
    }
}
