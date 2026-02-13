# Shoe Store Example App

This example app demonstrates how to integrate the MinFraudDevice SDK into a real-world eCommerce iOS application.

## Overview

The Shoe Store app is a fully functional eCommerce application that sells shoes and integrates fraud detection using the MinFraudDevice SDK. It showcases:

- Product browsing and search
- Shopping cart management
- Checkout flow with fraud detection
- Integration with MinFraudDevice SDK
- DeviceCheck token generation
- Fraud risk assessment display

## Features

### eCommerce Functionality
- **Product Catalog**: Browse a collection of shoes from various brands
- **Product Details**: View detailed information about each shoe
- **Size & Color Selection**: Choose preferred size and color options
- **Shopping Cart**: Add, remove, and manage cart items
- **Quantity Management**: Adjust quantities with an intuitive stepper
- **Order Summary**: Review purchase before checkout

### Fraud Detection Integration
- **Device Identification**: Retrieves persistent device ID using MinFraudDevice SDK
- **DeviceCheck Support**: Checks and displays DeviceCheck availability
- **Risk Assessment**: Analyzes transactions for fraud risk before checkout
- **Visual Indicators**: Color-coded risk levels (Low/Medium/High)
- **Transparent Display**: Shows device ID and fraud assessment to demonstrate SDK functionality

## Architecture

### Models
- **Shoe**: Product model with properties like name, brand, price, sizes, colors
- **CartItem**: Shopping cart item with shoe, size, color, and quantity

### Services
- **FraudDetectionService**: Manages MinFraudDevice SDK integration
  - Initializes SDK and retrieves device ID
  - Checks DeviceCheck support
  - Analyzes transactions for fraud risk
  - Demonstrates how to send data to your backend

### ViewModels
- **ShoeStoreViewModel**: Main view model managing app state
  - Product catalog
  - Shopping cart
  - Fraud detection coordination
  - Checkout process

### Views
- **ContentView**: Main navigation and tab structure
- **ProductListView**: Grid display of available shoes
- **ProductDetailView**: Detailed shoe view with size/color selection
- **CartView**: Shopping cart with item management
- **CheckoutView**: Checkout screen with fraud detection display

## Running the Example

### Requirements
- Xcode 15.0+
- iOS 15.0+ device or simulator
- MinFraudDevice SDK (included via local path)

### Setup

1. **Open the project:**
   ```bash
   cd Example/ShoeStoreApp
   open ShoeStoreApp.xcodeproj
   ```

2. **Build and run:**
   - Select a target device or simulator
   - Press Cmd+R to build and run

3. **Explore the app:**
   - Browse the shoe catalog
   - Add items to your cart
   - Proceed to checkout
   - Observe the fraud detection in action

## Integration Guide

This example demonstrates the key integration points for MinFraudDevice SDK:

### 1. Initialize SDK
```swift
import MinFraudDevice

// Get the shared instance
let sdk = MinFraudDevice.shared
```

### 2. Get Device ID
```swift
if let deviceId = sdk.getDeviceId() {
    // Send to your backend for fraud analysis
    print("Device ID: \(deviceId)")
}
```

### 3. Check DeviceCheck Support
```swift
let isSupported = sdk.isDeviceCheckSupported()
```

### 4. Generate DeviceCheck Token
```swift
let result = await sdk.generateDeviceCheckTokenString()
switch result {
case .success(let token):
    // Send token to your backend
    // Your backend uses Apple's DeviceCheck API
case .failure(let error):
    // Handle error
    print(error.localizedDescription)
}
```

### 5. Send to Backend
The `FraudDetectionService` demonstrates how to structure your backend communication:

```swift
struct FraudAssessmentRequest {
    let deviceId: String
    let deviceCheckToken: String?
    let amount: Double
    let itemCount: Int
    let timestamp: Date
}

// POST to your backend
// Your backend forwards device data to MaxMind minFraud API
// Returns risk assessment to your app
```

## Code Walkthrough

### FraudDetectionService.swift

The fraud detection service shows the complete integration pattern:

1. **Initialization**: Gets device ID when service is created
2. **Transaction Analysis**: Mock implementation showing backend communication structure
3. **Risk Calculation**: Demonstrates how risk scores translate to risk levels
4. **Backend Integration**: Placeholder showing how to structure API calls

**Key Methods:**
- `initializeSDK()`: Sets up MinFraudDevice SDK
- `analyzeTransaction()`: Analyzes a transaction for fraud
- `sendToBackend()`: Example backend communication structure

### CheckoutView.swift

The checkout view demonstrates the user-facing fraud detection display:

- Shows device ID (for transparency/debugging)
- Displays DeviceCheck support status
- Shows real-time fraud analysis
- Color-coded risk level indicators
- Prevents checkout until fraud analysis completes

## Customization

### Using Real MinFraud API

To connect to the actual MinFraud API:

1. Update `FraudDetectionService.swift` to uncomment the MinFraudDevice import
2. Implement the `sendToBackend()` method with your API endpoint
3. Your backend should:
   - Receive device ID and DeviceCheck token
   - Forward to MaxMind minFraud API
   - Apply DeviceCheck token to Apple's API
   - Return risk assessment to your app

### Styling

The app uses SwiftUI with customizable styling:
- Colors can be adjusted in each view
- Risk level colors are defined in `FraudDetectionService`
- Product cards and layouts can be modified in view files

### Mock Data

Sample shoes are defined in `Shoe.swift`:
- Add or modify shoes in `Shoe.sampleShoes`
- Update properties like price, sizes, colors
- Add real product images to Assets.xcassets

## Privacy Considerations

This example app demonstrates privacy-compliant fraud detection:

- **Transparent**: Device ID is shown to users
- **No PII**: No collection of personal identifiable information
- **Apple-Compliant**: Uses only approved APIs (IDFV, DeviceCheck)
- **Purpose-Specific**: Fraud detection is clearly communicated

## Best Practices Demonstrated

1. **Early SDK Initialization**: SDK initialized when app launches
2. **Async Operations**: All SDK calls use async/await
3. **Error Handling**: Proper error handling for SDK operations
4. **User Feedback**: Loading indicators during fraud analysis
5. **Graceful Degradation**: App works even if DeviceCheck unavailable
6. **Backend Integration**: Clear separation of client and server responsibilities

## Support

For questions about this example app or SDK integration:
- Review the MinFraudDevice SDK documentation
- Check the inline code comments
- Contact MaxMind support

## License

This example app is provided as-is for demonstration purposes.
See the main LICENSE file for SDK licensing terms.
