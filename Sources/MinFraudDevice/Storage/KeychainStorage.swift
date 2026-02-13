import Foundation
import os
import Security

protocol KeychainStoring: Sendable {
    func get(forKey key: String) -> String?
    func set(_ value: String, forKey key: String) -> Bool
}

final class KeychainStorage: KeychainStoring, @unchecked Sendable {
    static let service = SDKConfig.identifier

    static let idfvKey = "idfv"
    static let trackingTokenKey = "tracking_token"

    private let logger: Logger?

    init(logger: Logger? = nil) {
        self.logger = logger
    }

    func get(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KeychainStorage.service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            logger?.error("Keychain get failed for key '\(key)' with status \(status)")
            return nil
        }

        guard let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            logger?.error("Keychain get for key '\(key)' returned data that could not be decoded as UTF-8")
            return nil
        }

        return value
    }

    @discardableResult
    func set(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KeychainStorage.service,
            kSecAttrAccount as String: key
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecAttrSynchronizable as String: false
        ]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if updateStatus == errSecItemNotFound {
            let addQuery = query.merging(attributes) { _, new in new }
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            if addStatus != errSecSuccess {
                logger?.error("Keychain add failed for key '\(key)' with status \(addStatus)")
            }
            return addStatus == errSecSuccess
        }

        if updateStatus != errSecSuccess {
            logger?.error("Keychain update failed for key '\(key)' with status \(updateStatus)")
        }

        return updateStatus == errSecSuccess
    }
}
