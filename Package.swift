// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Adyen",
    defaultLocalization: "en-US",
    platforms: [
        .iOS(.v10),
    ],
    products: [
        .library(
            name: "Adyen",
            targets: ["Adyen"]
        ),
        .library(
            name: "AdyenCard",
            targets: ["AdyenCard"]
        ),
        .library(
            name: "AdyenDropIn",
            targets: ["AdyenDropIn"]
        ),
        .library(
            name: "AdyenWeChatPay",
            targets: ["AdyenWeChatPay"]
        ),
    ],
    dependencies: [
        .package(
            name: "Adyen3DS2",
            url: "https://github.com/Adyen/adyen-3ds2-ios",
            .exact(Version(2, 2, 1))
        ),
        .package(
            name: "AdyenWeChatPayInternal",
            url: "https://github.com/Adyen/adyen-wechatpay-ios",
            .exact(Version(1, 0, 0))
        ),
    ],
    targets: [
        .target(
            name: "Adyen",
            dependencies: [],
            path: "Adyen",
            exclude: [
                "Info.plist",
                "Utilities/Non SPM Bundle Extension", // This is to exclude `BundleExtension.swift` file, since swift packages has different code to access internal resources.
            ]
        ),
        .target(
            name: "AdyenCard",
            dependencies: [
                .target(name: "Adyen"),
                .product(name: "Adyen3DS2", package: "Adyen3DS2"),
            ],
            path: "AdyenCard",
            exclude: [
                "Info.plist",
                "Utilities/Non SPM Bundle Extension", // This is to exclude `BundleExtension.swift` file, since swift packages has different code to access internal resources.
            ]
        ),
        .target(
            name: "AdyenDropIn",
            dependencies: [
                .target(name: "AdyenCard"),
            ],
            path: "AdyenDropIn",
            exclude: ["Info.plist"]
        ),
        .target(
            name: "AdyenWeChatPay",
            dependencies: [
                .product(name: "AdyenWeChatPayInternal", package: "AdyenWeChatPayInternal"),
                .target(name: "Adyen"),
            ],
            path: "AdyenWeChatPay/WeChatPayActionComponent"
        ),
    ]
)
