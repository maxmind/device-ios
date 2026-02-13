# Contributing to MinFraudDevice iOS SDK

Thank you for your interest in contributing to the MinFraudDevice iOS SDK! This document provides guidelines for contributing to the project.

## Code of Conduct

Please be respectful and constructive in all interactions with the project and community.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue on GitHub with:
- A clear, descriptive title
- Steps to reproduce the issue
- Expected behavior vs. actual behavior
- iOS version and device information
- Code samples if applicable

### Suggesting Enhancements

Enhancement suggestions are welcome! Please open an issue with:
- A clear description of the enhancement
- Use cases and benefits
- Any potential implementation ideas

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following the coding standards below
3. **Add tests** for any new functionality
4. **Update documentation** if needed (README, code comments, etc.)
5. **Ensure tests pass** by running the test suite
6. **Submit a pull request** with a clear description of the changes

## Development Setup

### Prerequisites

- Xcode 15.0 or later
- Swift 5.9 or later
- iOS 15.0+ device or simulator for testing

### Building the Package

```bash
# Open the package in Xcode
open Package.swift

# Or build from command line
swift build
```

### Running Tests

```bash
# Run tests from command line
swift test

# Or use Xcode
# Cmd+U to run all tests
```

## Coding Standards

### Swift Style Guide

- Follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use 4 spaces for indentation (no tabs)
- Keep lines under 120 characters when possible
- Use meaningful variable and function names

### Documentation

- Add documentation comments for all public APIs
- Use `///` for documentation comments
- Include parameter descriptions and return values
- Provide usage examples for complex functionality

Example:
```swift
/// Retrieves the persistent device identifier.
///
/// This method returns a UUID-format identifier that persists across
/// app reinstalls when possible.
///
/// - Returns: The device identifier string, or nil if unavailable
public func getDeviceId() -> String?
```

### Testing

- Write unit tests for new functionality
- Aim for high test coverage
- Use descriptive test names: `testFeature_Condition_ExpectedResult()`
- Keep tests focused and independent

### Privacy & Compliance

- All code must comply with Apple's privacy guidelines
- Update `PrivacyInfo.xcprivacy` if collecting new data types
- Document privacy implications in code comments
- Never collect personal identifiable information (PII)

## Release Process

Releases are managed by the MaxMind team. Contributors should:
- Ensure changes are documented in CHANGELOG.md
- Follow semantic versioning principles
- Update version numbers only when instructed

## Questions?

If you have questions about contributing, please:
- Check existing issues and discussions
- Open a new issue with the "question" label
- Contact MaxMind support for general inquiries

## License

By contributing, you agree that your contributions will be licensed under the same Apache 2.0 License that covers the project.
