// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdyenWeChatPayInternal",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "AdyenWeChatPayInternal",
            targets: ["AdyenWeChatPayInternal"])
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "AdyenWeChatPayInternal",
            path: "AdyenWeChatPayInternal.xcframework")
    ]
)
