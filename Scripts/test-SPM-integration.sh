#!/bin/bash

set -e # Any subsequent(*) commands which fail will cause the shell script to exit immediately

PROJECT_NAME=TempProject

# Clean up.
rm -rf $PROJECT_NAME

mkdir -p $PROJECT_NAME && cd $PROJECT_NAME

# Create the package.
swift package init

# Create the Package.swift.
echo "// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: \"TempProject\",
    defaultLocalization: \"en-US\",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: \"TempProject\",
            targets: [\"TempProject\"]
        )
    ],
    dependencies: [
        .package(name: \"Adyen\", path: \"../\")
    ],
    targets: [
        .target(
            name: \"TempProject\",
            dependencies: [
                .product(name: \"Adyen\", package: \"Adyen\"),
                .product(name: \"AdyenActions\", package: \"Adyen\"),
                .product(name: \"AdyenCard\", package: \"Adyen\"),
                .product(name: \"AdyenComponents\", package: \"Adyen\"),
                .product(name: \"AdyenSession\", package: \"Adyen\"),
                .product(name: \"AdyenDropIn\", package: \"Adyen\"),
                .product(name: \"AdyenWeChatPay\", package: \"Adyen\"),
                .product(name: \"AdyenSwiftUI\", package: \"Adyen\"),
                .product(name: \"AdyenCashAppPay\", package: \"Adyen\"),
                .product(name: \"AdyenDelegatedAuthentication\", package: \"Adyen\")
            ]
        )
    ]
)
" > Package.swift

swift package update

# This is a hack to work around a bug with SPM
# https://github.com/apple/swift-package-manager/issues/5767#issuecomment-1258214979
swift package dump-pif > /dev/null || true
xcodebuild clean -scheme TempProject -destination 'generic/platform=iOS' > /dev/null || true

# Archive for generic iOS device
echo '############# Archive for generic iOS device ###############'
xcodebuild archive -scheme TempProject -destination 'generic/platform=iOS' -skipPackagePluginValidation

# Build for generic iOS device
echo '############# Build for generic iOS device ###############'
xcodebuild build -scheme TempProject -destination 'generic/platform=iOS' -skipPackagePluginValidation

# Archive for x86_64 simulator
echo '############# Archive for x86_64 simulator ###############'
xcodebuild archive -scheme TempProject -destination 'generic/platform=iOS Simulator' ARCHS=x86_64 -skipPackagePluginValidation

# Build for x86_64 simulator
echo '############# Build for x86_64 simulator ###############'
xcodebuild build -scheme TempProject -destination 'generic/platform=iOS Simulator' ARCHS=x86_64 -skipPackagePluginValidation

# Clean up.
cd ../
rm -rf $PROJECT_NAME
