# MinFraudDevice iOS SDK

A Swift SDK for MaxMind minFraud device identification that provides Apple-compliant device fingerprinting for fraud detection purposes.

## Features

- **Apple-Compliant**: Uses IDFV (Identifier for Vendor) with keychain persistence
- **DeviceCheck Integration**: Server-side fraud state management with Apple's DeviceCheck framework
- **Privacy-First**: Transparent data collection with Privacy Manifest included
- **Persistent**: Device identifier survives app reinstalls in most cases
- **Simple API**: Easy-to-use singleton interface with async/await support
- **Swift Package Manager**: Native SPM support for easy integration
- **Example App**: Complete eCommerce demo showing SDK integration

## Requirements

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add MinFraudDevice to your project using Xcode:

1. In Xcode, select **File** → **Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/maxmind/device-ios` (when published)
3. Select the version you want to use

Or add it to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/maxmind/device-ios", from: "1.0.0")
]
```

## Usage

### Basic Usage

```swift
import MinFraudDevice

// Get the shared instance
let sdk = MinFraudDevice.shared

// Retrieve the device identifier
if let deviceId = sdk.getDeviceId() {
    print("Device ID: \(deviceId)")
    // Send this ID to your backend for fraud analysis
}
```

### DeviceCheck Integration (Advanced)

For enhanced fraud detection, use DeviceCheck to maintain server-side fraud state:

```swift
import MinFraudDevice

let sdk = MinFraudDevice.shared

// Check if DeviceCheck is supported
if sdk.isDeviceCheckSupported() {
    // Generate a token for your backend
    let result = await sdk.generateDeviceCheckTokenString()

    switch result {
    case .success(let token):
        // Send token to your backend
        // Your backend uses Apple's DeviceCheck API to:
        // - Query fraud state (2 bits per device)
        // - Update fraud state
        print("DeviceCheck token: \(token)")

    case .failure(let error):
        print("Error generating token: \(error.localizedDescription)")
    }
}
```

**Important**: DeviceCheck tokens must be validated on your server using Apple's DeviceCheck API. See [Apple's DeviceCheck documentation](https://developer.apple.com/documentation/devicecheck) for server-side implementation.

### Integration with React Native

This SDK can be easily wrapped for React Native usage. Create a native module that exposes the `getDeviceId()` method:

```swift
import MinFraudDevice

@objc(MinFraudDeviceModule)
class MinFraudDeviceModule: NSObject {
    @objc
    func getDeviceId(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if let deviceId = MinFraudDevice.shared.getDeviceId() {
            resolve(deviceId)
        } else {
            reject("ERROR", "Unable to retrieve device ID", nil)
        }
    }
}
```

## Example App

A complete eCommerce example app is included in the `Example/` directory. The Shoe Store app demonstrates:

- Full shopping experience (browse products, cart, checkout)
- SDK integration in a real-world scenario
- DeviceCheck token generation
- Fraud risk assessment display
- Best practices for implementation

To run the example:
```bash
cd Example/ShoeStoreApp
open ShoeStoreApp.xcodeproj
```

See [Example/README.md](Example/README.md) for detailed documentation.

## How It Works

The MinFraudDevice SDK uses a multi-tier identification approach:

1. **IDFV (Identifier for Vendor)**: Uses the system-provided identifier that's unique to your vendor
2. **Keychain Persistence**: Stores the IDFV in the keychain to maintain consistency across app reinstalls
3. **DeviceCheck (Optional)**: Provides server-side fraud state that persists even after factory reset

### Device ID Persistence

The device identifier will remain the same for:
- Multiple app launches
- App updates
- Device reboots
- App reinstalls (in most cases)

The device identifier will change if:
- The user uninstalls all apps from your vendor
- The device is factory reset
- The user restores from a backup made on a different device

## Privacy & Compliance

This SDK is designed to be fully compliant with Apple's privacy requirements:

- ✅ Uses Apple-sanctioned APIs (IDFV, Keychain, DeviceCheck)
- ✅ Includes Privacy Manifest (`PrivacyInfo.xcprivacy`)
- ✅ No tracking or cross-app identification
- ✅ No "Required Reason" APIs used
- ✅ Clear fraud prevention purpose
- ✅ DeviceCheck recommended by Apple for fraud detection

The SDK collects:
- **Device ID**: IDFV for device identification
- **Purpose**: Fraud prevention and security

All data collection is transparently declared in the included Privacy Manifest.

## Architecture

The SDK currently includes:

- **Phase 1**: Core device identification using IDFV + Keychain ✅
- **Phase 2**: DeviceCheck integration for server-side fraud state management ✅
- **Phase 3**: Additional device context (OS version, model, screen size) - Considered for future implementation

The modular architecture allows you to use just device identification, or add DeviceCheck for enhanced fraud detection capabilities.

## License

Copyright (c) 2024-2026 MaxMind, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Support

For questions or issues, please visit:
- [MaxMind Support](https://support.maxmind.com/)
- [GitHub Issues](https://github.com/maxmind/device-ios/issues) (when published)

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting pull requests.
