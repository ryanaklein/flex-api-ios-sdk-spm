// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlexAPIiOSSDK",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "FlexAPIiOSSDK",
            targets: ["FlexAPIiOSSDK"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "FlexAPIiOSSDK",
            dependencies: [],
            resources: [
                .process("Internal/keys")
            ]),
        .testTarget(
            name: "FlexAPIiOSSDKTests",
            dependencies: ["FlexAPIiOSSDK"],
            resources: [
                .process("rsa_public_key"),
                .process("Shared/JWE/Helpers/TestKeys.plist")
            ]),
    ]
)