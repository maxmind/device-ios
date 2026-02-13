import Foundation
import os

/// Errors that can occur during device tracking operations.
public enum MinFraudDeviceError: Error, LocalizedError, Equatable {
    /// The Identifier for Vendor (IDFV) could not be obtained from the system or keychain.
    case idfvUnavailable

    /// The server response did not include a tracking token.
    case missingTrackingToken

    public var errorDescription: String? {
        switch self {
        case .idfvUnavailable:
            return "Unable to obtain an Identifier for Vendor (IDFV)"
        case .missingTrackingToken:
            return "Server response did not include a tracking token"
        }
    }
}

/// Main entry point for the MinFraud Device SDK.
///
/// Create an instance with an ``SDKConfig``, then call ``collectAndSend()``
/// to collect device data and send it to MaxMind servers. The returned
/// ``TrackingResult`` contains a tracking token to pass to the minFraud API.
///
/// ```swift
/// let config = SDKConfig(accountID: 123456)
/// let tracker = DeviceTracker(config: config)
///
/// let result = try await tracker.collectAndSend()
/// sendToBackend(trackingToken: result.trackingToken)
/// ```
public final class DeviceTracker: @unchecked Sendable {
    private let config: SDKConfig
    private let collector: DeviceDataCollector
    private let apiClient: DeviceAPIClient
    private let storage: KeychainStoring
    private let logger: Logger?

    private let lock = NSLock()
    private var automaticCollectionTask: Task<Void, Never>?

    /// Creates a new device tracker with the given configuration.
    ///
    /// If ``SDKConfig/collectionIntervalSeconds`` is greater than zero,
    /// automatic collection begins immediately.
    ///
    /// - Parameter config: The SDK configuration.
    public init(config: SDKConfig) {
        self.config = config
        let logger: Logger? = config.loggingEnabled
            ? Logger(subsystem: SDKConfig.identifier, category: "DeviceTracker")
            : nil
        self.logger = logger
        let storage = KeychainStorage(logger: logger)
        self.storage = storage
        self.collector = DeviceDataCollector(storage: storage, logger: logger)
        self.apiClient = DeviceAPIClient(config: config, logger: logger)

        logger?.info("MaxMind Device Tracker initialized")

        if config.collectionIntervalSeconds > 0 {
            startAutomaticCollection()
        }
    }

    // Support dependency injection, primarily for tests.
    init(config: SDKConfig, collector: DeviceDataCollector, apiClient: DeviceAPIClient, storage: KeychainStoring) {
        self.config = config
        self.collector = collector
        self.apiClient = apiClient
        self.storage = storage
        self.logger = nil

        if config.collectionIntervalSeconds > 0 {
            startAutomaticCollection()
        }
    }

    /// Collects device data and sends it to MaxMind servers.
    ///
    /// On success, the tracking token is persisted in the keychain for
    /// inclusion in subsequent requests.
    ///
    /// - Returns: A ``TrackingResult`` containing the tracking token.
    /// - Throws: ``MinFraudDeviceError/idfvUnavailable`` if the device
    ///   identifier cannot be obtained, ``MinFraudDeviceError/missingTrackingToken``
    ///   if the server response does not include a token, or an ``APIError``
    ///   if the network request fails.
    public func collectAndSend() async throws -> TrackingResult {
        let deviceData = try collector.collect()
        let response = try await apiClient.sendDeviceData(deviceData)

        guard let token = response.trackingToken,
              !token.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw MinFraudDeviceError.missingTrackingToken
        }

        if storage.set(token, forKey: KeychainStorage.trackingTokenKey) {
            logger?.debug("Tracking token saved from server response")
        }

        return TrackingResult(trackingToken: token)
    }

    /// Cancels automatic collection and releases resources.
    ///
    /// Call this method when the tracker is no longer needed.
    public func shutdown() {
        lock.lock()
        defer { lock.unlock() }
        automaticCollectionTask?.cancel()
        automaticCollectionTask = nil

        logger?.info("MaxMind Device Tracker shut down")
    }

    private func startAutomaticCollection() {
        let intervalNanoseconds = UInt64(config.collectionIntervalSeconds) * 1_000_000_000
        lock.lock()
        defer { lock.unlock() }
        automaticCollectionTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                do {
                    _ = try await self.collectAndSend()
                    self.logger?.debug("Automatic device data collection completed")
                } catch {
                    self.logger?.error("Automatic collection failed: \(error.localizedDescription)")
                }
                do {
                    try await Task.sleep(nanoseconds: intervalNanoseconds)
                } catch {
                    return
                }
            }
        }
    }

    deinit {
        lock.lock()
        defer { lock.unlock() }
        automaticCollectionTask?.cancel()
    }
}
