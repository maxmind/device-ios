import Foundation

struct DeviceData: Encodable, Sendable {
    let idfv: String
    let storedID: String?
    let requestDurationMS: Int?

    enum CodingKeys: String, CodingKey {
        case idfv
        case storedID = "stored_id"
        case requestDurationMS = "request_duration"
    }
}
