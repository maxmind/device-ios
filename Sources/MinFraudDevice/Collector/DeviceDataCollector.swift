import Foundation
import os
import UIKit

final class DeviceDataCollector: @unchecked Sendable {
    private let storage: KeychainStoring
    private let idfvProvider: () -> String?
    private let logger: Logger?

    init(
        storage: KeychainStoring = KeychainStorage(),
        idfvProvider: @escaping () -> String? = {
            UIDevice.current.identifierForVendor?.uuidString
        },
        logger: Logger? = nil
    ) {
        self.storage = storage
        self.idfvProvider = idfvProvider
        self.logger = logger
    }

    func collect() throws -> DeviceData {
        let idfv = try resolveIDFV()
        let trackingToken = storage.get(forKey: KeychainStorage.trackingTokenKey)

        return DeviceData(
            idfv: idfv,
            trackingToken: trackingToken,
            requestDurationMS: nil
        )
    }

    private func resolveIDFV() throws -> String {
        if let cached = storage.get(forKey: KeychainStorage.idfvKey) {
            return cached
        }

        guard let systemIDFV = idfvProvider() else {
            throw MinFraudDeviceError.idfvUnavailable
        }

        if !storage.set(systemIDFV, forKey: KeychainStorage.idfvKey) {
            logger?.warning("Failed to cache IDFV in keychain")
        }

        return systemIDFV
    }
}
