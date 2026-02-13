import Foundation
import Security
import UIKit

/// Manages persistent device identification using IDFV with keychain storage.
///
/// This implementation uses the Identifier for Vendor (IDFV) as the base device identifier
/// and persists it in the keychain to maintain consistency across app reinstalls.
class DeviceIdentifier {

    // MARK: - Constants

    private let keychainService = "com.maxmind.minfraud.device"
    private let deviceIdKey = "persistent_device_id"

    // MARK: - Public Methods

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

    // MARK: - Private Methods

    /// Loads the device identifier from the keychain.
    ///
    /// - Returns: The stored device identifier, or nil if not found or an error occurs
    private func loadFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: deviceIdKey,
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

    /// Stores the device identifier in the keychain.
    ///
    /// Uses kSecAttrAccessibleWhenUnlockedThisDeviceOnly for security,
    /// which provides a good balance of persistence and security.
    ///
    /// - Parameter identifier: The device identifier to store
    private func storeInKeychain(_ identifier: String) {
        guard let data = identifier.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: deviceIdKey,
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
