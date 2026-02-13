# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial implementation of MinFraudDevice SDK
- IDFV-based device identification
- Keychain persistence for device identifier
- DeviceCheck integration for server-side fraud state management (Phase 2)
- DeviceCheck token generation (binary data and base64 string formats)
- Privacy Manifest (PrivacyInfo.xcprivacy)
- Swift Package Manager support
- Comprehensive documentation
- Unit tests for core functionality and DeviceCheck
- CI/CD setup with GitHub Actions
  - Automated testing on multiple iOS versions
  - SwiftLint integration
  - Documentation generation
  - Privacy manifest validation
  - Automated releases
- Example app: Shoe Store eCommerce application
  - Complete shopping flow (browse, cart, checkout)
  - Fraud detection integration demonstration
  - DeviceCheck token generation example
  - Risk assessment visualization
  - Best practices for SDK integration

## [1.0.0] - TBD

### Added
- Phase 1 & 2: Device identification and DeviceCheck integration
  - Core device identification using IDFV + Keychain
  - DeviceCheck framework integration for persistent fraud state
- Apple-compliant privacy implementation
- iOS 15+ support
- Simple singleton API with async/await support
- React Native integration guidance
- Production-ready CI/CD pipeline
- Comprehensive example application

[Unreleased]: https://github.com/maxmind/device-ios/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/maxmind/device-ios/releases/tag/v1.0.0
