import Foundation

struct DeviceData: Encodable {
    let idfv: String
    let trackingToken: String?
    let requestDurationMS: Int?

    enum CodingKeys: String, CodingKey {
        case idfv
        case trackingToken = "tracking_token"
        case requestDurationMS = "request_duration"
    }
}
