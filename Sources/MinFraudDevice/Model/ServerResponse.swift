import Foundation

struct ServerResponse: Decodable {
    let trackingToken: String?
    let ipVersion: Int?

    enum CodingKeys: String, CodingKey {
        case trackingToken = "tracking_token"
        case ipVersion = "ip_version"
    }
}
