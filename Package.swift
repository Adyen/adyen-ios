// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Adyen",
    defaultLocalization: "en-US",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "AdyenCore",
            targets: ["Adyen"]),
        .library(
            name: "AdyenCard",
            targets: ["AdyenCard"]),
        .library(
            name: "AdyenDropIn",
            targets: ["AdyenDropIn"]),
        .library(
            name: "AdyenWeChatPay",
            targets: ["AdyenWeChatPay"])
    ],
    dependencies: [
        .package(name: "Adyen3DS2",
                 url: "file:///Users/mohamede/Documents/ios-code-base/adyen-3ds2-ios-public",
                 .branch("swift-package-manager"))
    ],
    targets: [
        .target(
            name: "Adyen",
            dependencies: [],
            path: "Adyen",
            exclude: [
                "Info.plist",
                "Utilities/Bundle Extension" // This to exclude `BundleExtension.swift` file, since swift packages has different code to access internal resources.
            ]),
        .target(
            name: "AdyenCard",
            dependencies: [
                .target(name: "Adyen"),
                .product(name: "Adyen3DS2", package: "Adyen3DS2")],
            path: "AdyenCard",
            exclude: ["Info.plist"]),
        .target(
            name: "AdyenDropIn",
            dependencies: [
                .target(name: "AdyenCard"),
                .target(name: "Adyen")],
            path: "AdyenDropIn",
            exclude: ["Info.plist"]),
        .target(
            name: "AdyenWeChatPay",
            dependencies: [
                .target(name: "AdyenWeChatPayInternal"),
                .target(name: "Adyen")],
            path: "AdyenWeChatPay/WeChatPayActionComponent",
            linkerSettings: [
                .linkedFramework("CFNetwork"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("CoreTelephony"),
                .linkedFramework("SystemConfiguration"),
                .linkedFramework("Security"),
                .linkedLibrary("c++"),
                .linkedLibrary("sqlite3"),
                .linkedLibrary("z")]),
        .binaryTarget(
            name: "AdyenWeChatPayInternal",
            path: "AdyenWeChatPay/WeChatSDK/libWeChatSDK.xcframework")
    ]
)
