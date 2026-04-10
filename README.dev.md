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
3. Update the version in the README.md installation example if needed.
4. Update `CHANGELOG.md`: set the release date and document any final changes.
5. Verify the privacy manifest is up to date
   (`Sources/MinFraudDevice/Resources/PrivacyInfo.xcprivacy`).
6. Commit the changes, push the branch, and open a pull request.
7. Ensure all CI checks pass and merge the pull request.

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

## Version Numbering

This project follows [Semantic Versioning](https://semver.org/). Swift Package
Manager resolves versions from git tags.
