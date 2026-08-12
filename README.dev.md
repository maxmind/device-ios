# Release Procedure

## Pre-release

1. Create a release branch from `main`:

   ```bash
   git checkout main
   git pull
   git checkout -b release/X.Y.Z
   ```

2. Update the version constant in
   `Sources/MinFraudDevice/Config/SDKConfig.swift`.
3. Update `s.version` in `MinFraudDevice.podspec`. This must match the version
   constant in `SDKConfig.swift`.
4. Update the version in the README.md installation examples if needed. The
   CocoaPods example pins an exact `:tag`, so it needs updating every release.
5. Update `CHANGELOG.md`: set the release date and document any final changes.
6. Verify the privacy manifest is up to date
   (`Sources/MinFraudDevice/Resources/PrivacyInfo.xcprivacy`).
7. Commit the changes, push the branch, and open a pull request.
8. Ensure all CI checks pass and merge the pull request.

## Creating a Release

1. Create and push a version tag from `main`:

   ```bash
   git checkout main
   git pull
   git tag -a X.Y.Z -m "Release X.Y.Z"
   git push origin X.Y.Z
   ```

2. Create a GitHub release from the tag at
   <https://github.com/maxmind/device-ios/releases/new>.

   - Select the tag you just pushed.
   - Write release notes summarizing changes since the last release.

## Post-release

- Verify the new version is resolvable via Swift Package Manager by adding the
  package dependency in a fresh project.
- Verify the new version installs via CocoaPods in a fresh project, using
  `pod 'MinFraudDevice', :git => 'https://github.com/maxmind/device-ios.git', :tag => 'X.Y.Z'`.
  The podspec is only visible to CocoaPods at tags that contain it, so this
  cannot be checked before the tag is pushed.
- Update the version mentioned in the
  [dev docs](https://dev.maxmind.com/minfraud/track-devices/ios/#installation)
  (or create an issue to do so).

## Version Numbering

This project follows [Semantic Versioning](https://semver.org/). Swift Package
Manager resolves versions from git tags.
