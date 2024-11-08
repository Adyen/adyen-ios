// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Adyen",
    defaultLocalization: "en-us",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "Adyen",
            targets: ["Adyen"]
        ),
        .library(
            name: "AdyenEncryption",
            targets: ["AdyenEncryption"]
        ),
        .library(
            name: "AdyenSwiftUI",
            targets: ["AdyenSwiftUI"]
        ),
        .library(
            name: "AdyenActions",
            targets: ["AdyenActions"]
        ),
        .library(
            name: "AdyenCard",
            targets: ["AdyenCard"]
        ),
        .library(
            name: "AdyenComponents",
            targets: ["AdyenComponents"]
        ),
        .library(
            name: "AdyenSession",
            targets: ["AdyenSession"]
        ),
        .library(
            name: "AdyenDropIn",
            targets: ["AdyenDropIn"]
        ),
        .library(
            name: "AdyenWeChatPay",
            targets: ["AdyenWeChatPay"]
        ),
        .library(
            name: "AdyenCashAppPay",
            targets: ["AdyenCashAppPay"]
        ),
        .library(
            name: "AdyenTwint",
            targets: ["AdyenTwint"]
        ),
        .library(
            name: "AdyenDelegatedAuthentication",
            targets: ["AdyenDelegatedAuthentication"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/Adyen/adyen-3ds2-ios",
            exact: "2.4.2"
        ),
        .package(
            url: "https://github.com/Adyen/adyen-authentication-ios",
            exact: "3.1.0"
        ),
        .package(
            url: "https://github.com/Adyen/adyen-networking-ios",
            exact: "2.0.0"
        ),
        .package(
            url: "https://github.com/Adyen/adyen-wechatpay-ios",
            exact: "2.1.0"
        ),
        .package(
            url: "https://github.com/cashapp/cash-app-pay-ios-sdk",
            exact: "0.6.2"
        )
    ],
    targets: [
        .target(
            name: "Adyen",
            dependencies: [.product(name: "AdyenNetworking", package: "adyen-networking-ios")],
            path: "Adyen",
            exclude: [
                "Info.plist",
                "Utilities/Non SPM Bundle Extension" // This is to exclude `BundleExtension.swift` file, since swift packages has different code to access internal resources.
            ],
            resources: [.process("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "AdyenEncryption",
            path: "AdyenEncryption",
            exclude: ["Info.plist"]
        ),
        .target(
            name: "AdyenSwiftUI",
            dependencies: [],
            path: "AdyenSwiftUI",
            exclude: ["Info.plist"]
        ),
        .target(
            name: "AdyenActions",
            dependencies: [
                .target(name: "Adyen"),
                .product(name: "Adyen3DS2", package: "adyen-3ds2-ios")
            ],
            path: "AdyenActions",
            exclude: [
                "Info.plist",
                "Utilities/Non SPM Bundle Extension" // This is to exclude `BundleExtension.swift` file, since swift packages has different code to access internal resources.
            ]
        ),
        .target(
            name: "AdyenCard",
            dependencies: [
                .target(name: "Adyen"),
                .target(name: "AdyenEncryption")
            ],
            path: "AdyenCard",
            exclude: [
                "Info.plist",
                "Utilities/Non SPM Bundle Extension" // This is to exclude `BundleExtension.swift` file, since swift packages has different code to access internal resources.
            ]
        ),
        .target(
            name: "AdyenComponents",
            dependencies: [
                .target(name: "Adyen"),
                .target(name: "AdyenEncryption")
            ],
            path: "AdyenComponents",
            exclude: ["Info.plist"]
        ),
        .target(
            name: "AdyenSession",
            dependencies: [
                .target(name: "Adyen"),
                .target(name: "AdyenActions")
            ],
            path: "AdyenSession",
            exclude: ["Info.plist"]
        ),
        .target(
            name: "AdyenDropIn",
            dependencies: [
                .target(name: "AdyenCard"),
                .target(name: "AdyenComponents"),
                .target(name: "AdyenActions")
            ],
            path: "AdyenDropIn",
            exclude: ["Info.plist"]
        ),
        .target(
            name: "AdyenWeChatPay",
            dependencies: [
                .product(name: "AdyenWeChatPayInternal", package: "adyen-wechatpay-ios"),
                .target(name: "AdyenActions")
            ],
            path: "AdyenWeChatPay/WeChatPayActionComponent"
        ),
        .target(
            name: "AdyenCashAppPay",
            dependencies: [
                .target(name: "Adyen"),
                .product(name: "PayKit", package: "cash-app-pay-ios-sdk"),
                .product(name: "PayKitUI", package: "cash-app-pay-ios-sdk")
            ],
            path: "AdyenCashAppPay",
            exclude: ["Info.plist"]
        ),
        .target(
            name: "AdyenTwint",
            dependencies: [
                .target(name: "Adyen"),
                .target(name: "TwintSDK")
            ],
            path: "AdyenTwint",
            exclude: ["Info.plist"]
        ),
        .binaryTarget(
            name: "TwintSDK",
            path: "XCFramework/Dynamic/TwintSDK.xcframework"
        ),
        .target(
            name: "AdyenDelegatedAuthentication",
            dependencies: [.product(name: "AdyenAuthentication", package: "adyen-authentication-ios")],
            path: "AdyenDelegatedAuthentication",
            exclude: ["Info.plist"]
        )
    ]
)
