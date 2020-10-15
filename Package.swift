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
    dependencies: [],
    targets: [
        .target(
            name: "Adyen",
            dependencies: [],
            path: "Adyen",
            exclude: ["Info.plist"],
            resources: [
                .process("Assets")]),
        .target(
            name: "AdyenCard",
            dependencies: [
                .target(name: "Adyen"),
                .target(name: "Adyen3DS2")],
            path: "AdyenCard",
            exclude: ["Info.plist"],
            resources: [
                .process("Assets")]),
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
            path: "AdyenWeChatPay/WeChatSDK/libWeChatSDK.xcframework"),
        .binaryTarget(
            name: "Adyen3DS2",
            url: "https://github.com/Adyen/adyen-3ds2-ios/releases/download/2.1.0-rc.6/Adyen3DS2.xcframework.zip",
            checksum: "a9171749834b80aade7a7d5644c438cd59ba87077ec4db5d35a8e72bd43e1e9a")
    ]
)
