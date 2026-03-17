import Foundation
import Security
import UIKit

class DeviceIdentifier {
    private let keychainService = "com.maxmind.minfraud.device"
    private let deviceIDKey = "persistent_device_id"

    /// Retrieves the persistent device identifier.
    ///
    /// This method first attempts to load an existing identifier from the keychain.
    /// If no identifier exists, it retrieves the system IDFV and stores it in the keychain
    /// for future persistence across app reinstalls.
    ///
    /// - Returns: The device identifier string, or nil if IDFV is unavailable
    func getDeviceIdentifier() -> String? {
        // 1. Try keychain first (survives app uninstall)
        if let persistentId = loadFromKeychain() {
            return persistentId
        }

        // 2. Get system IDFV and store in keychain
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
        let status = SecItemCopyMatching(query as CFDictionary, &result)

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
            kSecAttrAccount as String: deviceIDKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Delete existing item if present
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            // Note: In production, this could be logged to your analytics system
            print("MinFraudDevice: Failed to store device identifier in keychain (status: \(status))")
        }
    }
}
