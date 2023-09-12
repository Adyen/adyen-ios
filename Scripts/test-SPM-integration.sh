#!/bin/bash

function echo_group {
  echo "::endgroup::"
  echo "::group:: $1"
}

set -e # Any subsequent(*) commands which fail will cause the shell script to exit immediately

PROJECT_NAME=TempProject

# Clean up.
rm -rf $PROJECT_NAME

mkdir -p $PROJECT_NAME && cd $PROJECT_NAME

# Create the package.
echo "::group::Create the package."

swift package init

# Create the Package.swift.
echo_group "Create the Package.swift."
echo "// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: \"$PROJECT_NAME\",
    defaultLocalization: \"en-US\",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: \"$PROJECT_NAME\",
            targets: [\"$PROJECT_NAME\"]
        )
    ],
    dependencies: [
        .package(name: \"Adyen\", path: \"../\"),
    ],
    targets: [
        .target(
            name: \"$PROJECT_NAME\",
            dependencies: [
                .product(name: \"Adyen\", package: \"Adyen\"),
                .product(name: \"AdyenActions\", package: \"Adyen\"),
                .product(name: \"AdyenCard\", package: \"Adyen\"),
                .product(name: \"AdyenComponents\", package: \"Adyen\"),
                .product(name: \"AdyenDropIn\", package: \"Adyen\"),
                .product(name: \"AdyenWeChatPay\", package: \"Adyen\"),
                .product(name: \"AdyenSwiftUI\", package: \"Adyen\")])
    ]
)
" > Package.swift

# Create the package.
echo_group "Create the package."
swift package update
xcodebuild -resolvePackageDependencies

MAX_ATTEMP=3
ATTEMPT=0
while [ -z $SUCCESS ] && [ "$ATTEMPT" -le "$MAX_ATTEMP" ]; do
  xcodebuild clean -scheme $PROJECT_NAME -destination 'generic/platform=iOS' | grep -q "CLEAN SUCCEEDED" && SUCCESS=true
  ATTEMPT=$(($ATTEMPT+1))
done

# Build for generic iOS device
echo_group "Build for generic iOS device"
xcodebuild build -scheme $PROJECT_NAME -destination 'generic/platform=iOS'

echo_group "Archive for generic iOS device"
xcodebuild archive -scheme $PROJECT_NAME -destination 'generic/platform=iOS'

# Build for x86_64 simulator
echo_group "Build for x86_64 simulator"
xcodebuild build -scheme $PROJECT_NAME -destination 'generic/platform=iOS Simulator' ARCHS=x86_64

echo_group "Archive for x86_64 simulator"
xcodebuild archive -scheme $PROJECT_NAME -destination 'generic/platform=iOS Simulator' ARCHS=x86_64

echo "::endgroup::"

# Clean up.
cd ../
rm -rf $PROJECT_NAME
