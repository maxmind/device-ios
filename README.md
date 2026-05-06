# MinFraud Device iOS SDK

[![Swift Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmaxmind%2Fdevice-ios%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/maxmind/device-ios)
[![Platform Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmaxmind%2Fdevice-ios%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/maxmind/device-ios)

iOS SDK for collecting and reporting device data to MaxMind.

## Requirements

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add the package dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/maxmind/device-ios.git", from: "0.1.0")
]
```

Or in Xcode: File > Add Package Dependencies and enter the repository URL.

## Usage

### 1. Initialize the Tracker

```swift
import MinFraudDevice

let config = SDKConfig(accountID: 123456)
let tracker = DeviceTracker(config: config)
```

### 2. Collect and Send Device Data

Use the tracking token in your calls to the minFraud API.

```swift
do {
    // Collect the device data and send to the minFraud Device API.
    let result = try await tracker.collectAndSend()

    // Provide the received tracking token to your backend to use with the
    // minFraud API.
    sendToBackend(trackingToken: result.trackingToken)
} catch {
    print("Failed to send device data: \(error)")
}
```

### Configuration Options

```swift
let config = SDKConfig(
    accountID: 123456,           // Your MaxMind account ID
    serverURL: nil,              // nil = default dual-stack servers
    loggingEnabled: false,       // enable logging via os.Logger
    collectionIntervalSeconds: 0 // 0 = disabled; 300–86400 = automatic collection interval in seconds
)
```

| Parameter                   | Type | Default    | Description                                                   |
| --------------------------- | ---- | ---------- | ------------------------------------------------------------- |
| `accountID`                 | Int  | _required_ | Your MaxMind account ID                                       |
| `serverURL`                 | URL? | `nil`      | Custom server URL (`nil` = default dual-stack servers)        |
| `loggingEnabled`            | Bool | `false`    | Enable logging via `os.Logger`                                |
| `collectionIntervalSeconds` | Int  | `0`        | Auto-collection interval in seconds (0 = disabled, 300–86400) |

### Automatic Collection

When `collectionIntervalSeconds` is set to a value between 300 and 86400, the
tracker automatically collects and sends device data at the specified interval:

```swift
let config = SDKConfig(accountID: 123456, collectionIntervalSeconds: 300) // every 5 minutes
let tracker = DeviceTracker(config: config)

// Later, when done:
tracker.shutdown()
```

### Shutdown

Call `shutdown()` to cancel automatic collection and release resources:

```swift
tracker.shutdown()
```

### Objective-C

The SDK provides Objective-C compatible wrapper classes with an `MM` prefix.

```objc
@import MinFraudDevice;

MMSDKConfig *config = [[MMSDKConfig alloc] initWithAccountID:123456];
if (!config) {
    // Handle invalid configuration
    return;
}
MMDeviceTracker *tracker = [[MMDeviceTracker alloc] initWithConfig:config];

[tracker collectAndSendWithCompletion:^(MMTrackingResult *result, NSError *error) {
    if (error) {
        NSLog(@"Failed to send device data: %@", error);
        return;
    }
    [self sendToBackend:result.trackingToken];
}];

// When done:
[tracker shutdown];
```

## Privacy

The SDK collects the Identifier for Vendor (IDFV) and persists it in the
Keychain. It does not use the Identifier for Advertisers (IDFA) or any tracking
frameworks. A
[privacy manifest](Sources/MinFraudDevice/Resources/PrivacyInfo.xcprivacy) is
bundled with the SDK.

## Development

The simulator destination in the commands below depends on your installed Xcode
version. To list available simulators, run `xcrun simctl list devicetypes`.

### Building

```bash
xcodebuild build -scheme MinFraudDevice -destination 'generic/platform=iOS Simulator'
```

### Testing

```bash
xcodebuild test -scheme MinFraudDevice -destination 'platform=iOS Simulator,name=iPhone 17'
```

### Code Quality

Run all linters and formatters via
[precious](https://github.com/houseabsolute/precious):

```bash
precious lint --all
```

This runs SwiftLint, yamllint, and prettier (for Markdown). You can also run
them individually:

```bash
swiftlint lint
yamllint .
npx prettier --check --parser markdown --prose-wrap always "**/*.md"
```

### Documentation

Generate API documentation with DocC:

```bash
xcodebuild docbuild -scheme MinFraudDevice -destination 'generic/platform=iOS Simulator' -derivedDataPath .build/docc
```

### Example App

A minimal SwiftUI example app is included at `Example/MinFraudDeviceExample/`.
Build it with:

```bash
xcodebuild build \
    -project Example/MinFraudDeviceExample/MinFraudDeviceExample.xcodeproj \
    -scheme MinFraudDeviceExample \
    -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Contributing

1. Fork the repository
2. Set up your development environment (see [SETUP.md](SETUP.md))
3. Create a feature branch
4. Make your changes
5. Run tests and code quality checks
6. Submit a pull request

## License

This software is Copyright (c) 2026 by MaxMind, Inc.

This is free software, licensed under the
[Apache License, Version 2.0](LICENSE-APACHE) or the [MIT License](LICENSE-MIT),
at your option.

## Support

For support, please visit
[maxmind.com/en/company/contact-us](https://www.maxmind.com/en/company/contact-us).

If you find a bug or have a feature request, please open an issue on
[GitHub](https://github.com/maxmind/device-ios/issues).
