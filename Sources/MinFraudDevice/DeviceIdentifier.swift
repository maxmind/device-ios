import Foundation
import Security
import UIKit
import os

final class DeviceIdentifier {
    private let keychain: KeychainStoring
    private let keychainService = "com.maxmind.minfraud.device"
    private let deviceIDKey = "persistent_device_id"
    private static let logger = Logger(subsystem: "com.maxmind.minfraud.device", category: "Keychain")

    init(keychain: KeychainStoring = SystemKeychainStore()) {
        self.keychain = keychain
    }

    var deviceID: String? {
        // 1. Try keychain first (survives app uninstall)
        if let persistentId = loadFromKeychain() {
            return persistentId
        }

        // 2. Get system IDFV
        guard let idfv = UIDevice.current.identifierForVendor?.uuidString else {
            return nil
        }

        // 3. Store IDFV in keychain for persistence
        storeInKeychain(idfv)
        return idfv
    }

    private func loadFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: deviceIDKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = keychain.copyMatching(query as CFDictionary, result: &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let identifier = String(data: data, encoding: .utf8) else {
            return nil
        }

        return identifier
    }

    private func storeInKeychain(_ identifier: String) {
        guard let data = identifier.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: deviceIDKey
        ]

        let attributesToUpdate: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = keychain.update(query as CFDictionary, attributes: attributesToUpdate as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            DeviceIdentifier.logger.debug("Keychain update failed (status: \(status, privacy: .public))")
            return
        }

        if status == errSecItemNotFound {
            let addQuery = query.merging(attributesToUpdate) { _, new in new }
            let addStatus = keychain.add(addQuery as CFDictionary)
            if addStatus != errSecSuccess {
                DeviceIdentifier.logger.debug("Keychain add failed (status: \(addStatus, privacy: .public))")
            }
        }
    }
}
