import Foundation

struct ServerResponse: Decodable, Sendable {
    let storedID: String
    let ipVersion: Int

    enum CodingKeys: String, CodingKey {
        case storedID = "stored_id"
        case ipVersion = "ip_version"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let rawStoredID = try container.decode(String.self, forKey: .storedID)
        guard !rawStoredID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DecodingError.dataCorruptedError(
                forKey: .storedID,
                in: container,
                debugDescription: "stored_id must not be blank"
            )
        }
        self.storedID = rawStoredID

        let rawIPVersion = try container.decode(Int.self, forKey: .ipVersion)
        guard rawIPVersion == 4 || rawIPVersion == 6 else {
            throw DecodingError.dataCorruptedError(
                forKey: .ipVersion,
                in: container,
                debugDescription: "ip_version must be 4 or 6, got \(rawIPVersion)"
            )
        }
        self.ipVersion = rawIPVersion
    }

    init(storedID: String, ipVersion: Int) {
        precondition(
            !storedID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            "stored_id must not be blank"
        )
        precondition(ipVersion == 4 || ipVersion == 6, "ip_version must be 4 or 6")
        self.storedID = storedID
        self.ipVersion = ipVersion
    }
}
