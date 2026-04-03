# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Project Overview

This is an iOS SDK for collecting device data and sending it to MaxMind servers
for device fingerprinting and fraud detection. The project uses Swift with Swift
Package Manager and targets iOS 15+.

**Key Design Principles:**

- No external dependencies (Foundation, UIKit, Security, os only)
- No singleton — users create and own `DeviceTracker` instances
- Swift concurrency (async/await) for all network operations
- Protocol-based abstractions for testability (e.g., `KeychainStoring`)
- Logging via `os.Logger`, disabled by default

## Naming Conventions

Follow Swift API Design Guidelines:

- All-caps for acronyms: `SDKConfig`, `DeviceAPIClient`, `IDFV`, `URL`
- Use "tracking token" in public API, "stored ID" internally and on the wire
- Time units as suffixes: `collectionIntervalSeconds`, `requestDurationMS`

## Build Commands

This SDK depends on UIKit and must be built with `xcodebuild`, not
`swift build`.

### Building

```bash
xcodebuild build -scheme MinFraudDevice -destination 'generic/platform=iOS Simulator'
```

### Testing

```bash
xcodebuild test -scheme MinFraudDevice -destination 'platform=iOS Simulator,name=iPhone 16'
```

### Code Quality

```bash
# Run all linters via precious
precious lint --all

# Individual tools
swiftlint lint
yamllint .
npx prettier --check --parser markdown --prose-wrap always "**/*.md"
```

### Documentation

```bash
xcodebuild docbuild -scheme MinFraudDevice -destination 'generic/platform=iOS Simulator' -derivedDataPath .build/docc
```

### Example App

```bash
xcodebuild build \
    -project Example/MinFraudDeviceExample/MinFraudDeviceExample.xcodeproj \
    -scheme MinFraudDeviceExample \
    -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Architecture

### Public API

`DeviceTracker` is the main entry point:

- `init(config:)` creates a tracker instance
- `collectAndSend()` collects device data and sends it to MaxMind servers
- `shutdown()` cancels automatic collection and releases resources

Unlike the Android sibling SDK, there is no singleton pattern. Users create
instances directly.

Objective-C compatible wrappers (`MMSDKConfig`, `MMDeviceTracker`,
`MMTrackingResult`) live in `ObjC/` and wrap the Swift types with `NSObject`
subclasses and completion-handler APIs.

### Four-Layer Architecture

1. **Public API Layer** (`DeviceTracker.swift`)

   - Creates and owns internal components
   - Manages automatic collection lifecycle
   - Thread-safe via `NSLock` for mutable state

2. **Configuration Layer** (`Config/SDKConfig.swift`)

   - Immutable configuration with precondition validation
   - Default servers: `d-ipv6.mmapiws.com` and `d-ipv4.mmapiws.com`
   - Collection interval: 0 (disabled) or >= 300 seconds

3. **Data Collection Layer** (`Collector/DeviceDataCollector.swift`)

   - Retrieves IDFV from Keychain (cached) or system (`UIDevice`)
   - Reads stored ID from Keychain for inclusion in requests
   - Throws `MinFraudDeviceError.idfvUnavailable` if IDFV cannot be obtained

4. **Network Layer** (`Network/DeviceAPIClient.swift`)
   - URLSession-based HTTP client
   - Dual-stack IPv6/IPv4 flow (see below)
   - Throws `APIError.serverError` on non-success responses

### Dual-Request Flow (IPv6/IPv4)

To capture both IP addresses for a device:

1. POST to `d-ipv6.mmapiws.com/device/ios`
2. If response contains `ip_version: 6`, POST to `d-ipv4.mmapiws.com/device/ios`
   with request duration
3. IPv4 failure is non-fatal (logged, not propagated)
4. Stored ID from IPv6 response is persisted and returned as a tracking token

If a custom server URL is configured, dual-request is disabled.

### Storage

`KeychainStorage` persists IDFV and stored ID in the iOS Keychain:

- Service: `com.maxmind.minfraud.device`
- Accessibility: `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
- Synchronization: disabled (no iCloud Keychain sync)
- Errors are logged, not thrown

### Logging

A single `os.Logger` instance is created by `DeviceTracker` when
`loggingEnabled` is true, and passed to all internal components. When logging is
disabled, `logger` is `nil` and all `logger?.method()` calls are no-ops.

## Testing Strategy

- All tests use XCTest with async test methods
- `MockKeychainStorage` — dictionary-backed `KeychainStoring`
- `MockURLProtocol` — `URLProtocol` subclass for HTTP mocking
- Injectable IDFV provider via closure for `DeviceDataCollector`
- Table-driven tests use local structs for test cases
- Internal init on `DeviceTracker` supports dependency injection for tests

## Error Types

- `MinFraudDeviceError` (public) — `idfvUnavailable`
- `APIError` (public) — `serverError(statusCode:message:)`
