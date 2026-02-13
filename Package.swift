// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MinFraudDevice",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "MinFraudDevice",
            targets: ["MinFraudDevice"]
        )
    ],
    targets: [
        .target(
            name: "MinFraudDevice",
            resources: [.process("Resources/PrivacyInfo.xcprivacy")]
        ),
        .testTarget(
            name: "MinFraudDeviceTests",
            dependencies: ["MinFraudDevice"]
        )
    ]
)
