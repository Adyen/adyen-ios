#!/bin/bash

# Any subsequent(*) commands which fail will cause the shell script to exit immediately
set -euo pipefail 

function echo_header {
  echo " "
  echo "############# $1 #############"
}

function clean_up {
  cd ../
  rm -rf $PROJECT_NAME
  echo_header "Exited"
}

# Delete the temp folder if the script exited with error.
trap "clean_up" 0 1 2 3 6

PROJECT_NAME=TempProject

# Clean up.
rm -rf $PROJECT_NAME

mkdir -p $PROJECT_NAME && cd $PROJECT_NAME

echo_header 'Create a new Xcode project'
swift package init

# Create the Package.swift.
echo "// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: \"TempProject\",
    defaultLocalization: \"en-US\",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: \"TempProject\",
            targets: [\"TempProject\"]
        )
    ],
    dependencies: [
        .package(name: \"Adyen\", path: \"../\"),
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
                .product(name: \"AdyenSwiftUI\", package: \"Adyen\")])
    ]
)
" > Package.swift

echo_header 'Resolve packages'
swift package update
swift package resolve

# This is nececery to avoid internal PIF error
xcodebuild clean -scheme TempProject -destination 'generic/platform=iOS' > /dev/null

# Build and Archive for generic iOS device
echo_header 'Build for generic iOS device'
xcodebuild clean build archive -scheme TempProject -destination 'generic/platform=iOS' | xcpretty --utf --color

# Build and Archive for x86_64 simulator
echo_header 'Build for x86_64 simulator'
xcodebuild clean build archive -scheme TempProject -destination 'generic/platform=iOS Simulator' ARCHS=x86_64 | xcpretty --utf --color
