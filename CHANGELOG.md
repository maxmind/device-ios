# Changelog

## 0.1.2 (unreleased)

- Both license files are now included in the CocoaPods distribution. Previously
  only `LICENSE-APACHE` was vendored.
- The CocoaPods distribution now includes `README.md` instead of the internal
  release procedure, which was renamed from `README.dev.md` to `RELEASING.md`.

## 0.1.1 (2026-08-12)

- Added a CocoaPods podspec so the SDK can be installed with CocoaPods tooling
  from a git tag.
- Fixed `NSLock` use from asynchronous contexts in the Objective-C wrapper. This
  removes compiler warnings that are errors in Swift 6.

## 0.1.0 (2026-05-05)

- Initial release
