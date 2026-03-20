# Project Setup Guide

## Prerequisites

- **[Xcode](https://developer.apple.com/xcode/)** (latest stable recommended) —
  provides the Swift toolchain, iOS simulators, and `xcodebuild`. Required for
  building, testing, and running the SDK.
- **[SwiftLint](https://github.com/realm/SwiftLint)**
- **[yamllint](https://github.com/adrienverge/yamllint)**
- **[Node.js](https://nodejs.org/)** — for prettier (Markdown formatting)
- **[precious](https://github.com/houseabsolute/precious)** — runs all linters

## Building

```bash
xcodebuild build -scheme MinFraudDevice -destination 'generic/platform=iOS Simulator'
```

Note: `swift build` will not work because the SDK depends on UIKit. Use
`xcodebuild` for all build and test operations.

## Testing

```bash
xcodebuild test -scheme MinFraudDevice -destination 'platform=iOS Simulator,name=iPhone 16'
```

The simulator destination depends on your installed Xcode version. To list
available simulators, run `xcrun simctl list devicetypes`.

## Code Quality

Run all linters and formatters at once with precious:

```bash
precious lint --all
```

Or run them individually:

```bash
swiftlint lint
yamllint .
npx prettier --check --parser markdown --prose-wrap always "**/*.md"
```

## Example App

A minimal SwiftUI example app is included at `Example/MinFraudDeviceExample/`.
It references the SDK as a local package dependency.

To build:

```bash
xcodebuild build \
    -project Example/MinFraudDeviceExample/MinFraudDeviceExample.xcodeproj \
    -scheme MinFraudDeviceExample \
    -destination 'platform=iOS Simulator,name=iPhone 16'
```

To open in Xcode, open the `.xcodeproj` file. Xcode will automatically resolve
the local package dependency.

## Troubleshooting

### Xcode can't find simulators

Ensure you have iOS simulator runtimes installed:

```bash
xcodebuild -downloadPlatform iOS
```

## Next Steps

1. Review the [README.md](README.md) for API documentation and usage examples
2. Explore the example app in `Example/`
3. Run the tests
4. Start developing!
