# Getting Started with MinFraudDevice iOS SDK

This guide will help you quickly integrate the MinFraudDevice SDK into your iOS application.

## Quick Start (5 minutes)

### 1. Add the SDK to Your Project

**Using Xcode:**
1. Open your project in Xcode
2. Go to **File** → **Add Package Dependencies...**
3. Enter: `https://github.com/maxmind/device-ios`
4. Click **Add Package**

**Using Package.swift:**
```swift
dependencies: [
    .package(url: "https://github.com/maxmind/device-ios", from: "1.0.0")
]
```

### 2. Import and Use

```swift
import MinFraudDevice

class MyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get device ID
        if let deviceId = MinFraudDevice.shared.getDeviceId() {
            print("Device ID: \(deviceId)")
            // Send to your backend
        }
    }
}
```

### 3. Send to Your Backend

```swift
func sendDeviceInfoToBackend() async {
    let sdk = MinFraudDevice.shared

    guard let deviceId = sdk.getDeviceId() else {
        return
    }

    var deviceCheckToken: String?
    if sdk.isDeviceCheckSupported() {
        let result = await sdk.generateDeviceCheckTokenString()
        if case .success(let token) = result {
            deviceCheckToken = token
        }
    }

    // Create your API request
    let payload: [String: Any] = [
        "device_id": deviceId,
        "device_check_token": deviceCheckToken as Any,
        "transaction_data": [
            "amount": 99.99,
            "currency": "USD"
        ]
    ]

    // POST to your backend
    // Your backend forwards to MaxMind minFraud API
}
```

## Integration Checklist

- [ ] Add SDK to your project
- [ ] Import MinFraudDevice in relevant files
- [ ] Get device ID at appropriate time (app launch, before checkout, etc.)
- [ ] Check DeviceCheck support
- [ ] Generate DeviceCheck token for high-value transactions
- [ ] Send device data to your backend
- [ ] Configure your backend to use MaxMind minFraud API
- [ ] Implement DeviceCheck validation on your server
- [ ] Test on real device and simulator
- [ ] Verify Privacy Manifest is included in your app

## When to Call the SDK

### Option 1: App Launch (Recommended for Most Apps)
```swift
@main
struct MyApp: App {
    init() {
        // Initialize early to cache device ID
        _ = MinFraudDevice.shared.getDeviceId()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Option 2: Before Checkout (Recommended for eCommerce)
```swift
func beginCheckout() async {
    // Get device information
    let deviceId = MinFraudDevice.shared.getDeviceId()

    // Generate DeviceCheck token for this transaction
    let tokenResult = await MinFraudDevice.shared.generateDeviceCheckTokenString()

    // Proceed with checkout
    await processCheckout(deviceId: deviceId, token: tokenResult)
}
```

### Option 3: Before Sensitive Operations
```swift
func performSensitiveAction() async {
    // Account changes, password resets, etc.
    let deviceId = MinFraudDevice.shared.getDeviceId()

    // Send to backend for fraud check
    let isAllowed = await checkWithBackend(deviceId: deviceId)

    if isAllowed {
        // Proceed with action
    }
}
```

## Backend Integration

Your backend server needs to:

### 1. Receive Device Data from App
```json
{
  "device_id": "550e8400-e29b-41d4-a716-446655440000",
  "device_check_token": "base64_encoded_token...",
  "transaction": {
    "amount": 99.99,
    "currency": "USD"
  }
}
```

### 2. Forward to MaxMind minFraud API
```bash
curl -u <account_id>:<license_key> \
  --data '{
    "device": {
      "ip_address": "1.2.3.4",
      "user_agent": "Mozilla/5.0...",
      "session_id": "550e8400-e29b-41d4-a716-446655440000"
    },
    "order": {
      "amount": 99.99,
      "currency": "USD"
    }
  }' \
  https://minfraud.maxmind.com/minfraud/v2.0/score
```

### 3. Validate DeviceCheck Token (Optional)
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "device_token": "base64_encoded_token...",
    "transaction_id": "unique_id",
    "timestamp": 1234567890
  }' \
  https://api.devicecheck.apple.com/v1/query_two_bits
```

## Common Patterns

### Pattern 1: Simple Fraud Check
```swift
// Get device ID and send to backend
let deviceId = MinFraudDevice.shared.getDeviceId()
let riskScore = await yourBackend.checkFraud(deviceId: deviceId)

if riskScore > 0.7 {
    // High risk - require additional verification
} else {
    // Proceed normally
}
```

### Pattern 2: Enhanced with DeviceCheck
```swift
let sdk = MinFraudDevice.shared
let deviceId = sdk.getDeviceId()

var deviceCheckToken: String?
if sdk.isDeviceCheckSupported() {
    let result = await sdk.generateDeviceCheckTokenString()
    if case .success(let token) = result {
        deviceCheckToken = token
    }
}

let assessment = await yourBackend.assessRisk(
    deviceId: deviceId,
    deviceCheckToken: deviceCheckToken
)
```

### Pattern 3: With Error Handling
```swift
func getDeviceInfo() async -> DeviceInfo? {
    let sdk = MinFraudDevice.shared

    guard let deviceId = sdk.getDeviceId() else {
        // Log error - device ID unavailable
        return nil
    }

    var deviceCheckToken: String?
    if sdk.isDeviceCheckSupported() {
        let result = await sdk.generateDeviceCheckTokenString()

        switch result {
        case .success(let token):
            deviceCheckToken = token
        case .failure(let error):
            // Log warning - DeviceCheck unavailable
            print("DeviceCheck error: \(error)")
        }
    }

    return DeviceInfo(
        id: deviceId,
        deviceCheckToken: deviceCheckToken,
        isDeviceCheckSupported: sdk.isDeviceCheckSupported()
    )
}
```

## Testing

### On Simulator
- Device ID: ✅ Works
- DeviceCheck: ❌ Not supported (will return `.notSupported`)

### On Real Device
- Device ID: ✅ Works
- DeviceCheck: ✅ Works (requires iOS 11+)

### Testing Tips
1. Test with and without DeviceCheck support
2. Verify device ID persists across app launches
3. Test app reinstall to verify keychain persistence
4. Check that your backend handles missing DeviceCheck tokens gracefully

## Troubleshooting

### Device ID is nil
- **Cause**: IDFV can be nil in rare cases
- **Solution**: Handle nil gracefully, retry, or generate fallback ID

### DeviceCheck token generation fails
- **Cause**: Not supported on simulator, network issues, or rate limiting
- **Solution**: Always check `isDeviceCheckSupported()` first, handle failure cases

### Device ID changes unexpectedly
- **Possible causes**:
  - All vendor apps uninstalled
  - Device restore from different device backup
  - Keychain access issues
- **Solution**: This is expected behavior, treat as new device

## Next Steps

1. **Run the Example App**: See `Example/ShoeStoreApp` for a complete implementation
2. **Read the Full Documentation**: Check `README.md` for detailed API reference
3. **Set Up Your Backend**: Implement MaxMind minFraud API integration
4. **Configure DeviceCheck**: Set up Apple's DeviceCheck API on your server
5. **Test Thoroughly**: Test on real devices with real transactions

## Support

- **Documentation**: See README.md and Example/README.md
- **Issues**: Report at https://github.com/maxmind/device-ios/issues
- **MaxMind Support**: https://support.maxmind.com/

## Privacy Compliance

This SDK is designed for App Store approval:
- ✅ Privacy Manifest included
- ✅ No prohibited APIs
- ✅ Clear fraud prevention purpose
- ✅ No personal data collection
- ✅ Fully documented data usage

Always review Apple's latest privacy guidelines and ensure your app's privacy policy accurately describes data collection.
