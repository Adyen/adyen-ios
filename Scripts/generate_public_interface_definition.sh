#!/bin/bash

# TODO: Remove .build directory afterwards

# Building project in `.build` directory
echo "👷 Building project"
xcodebuild -derivedDataPath .build -sdk "`xcrun --sdk iphonesimulator --show-sdk-path`" -scheme "Adyen" -destination "platform=iOS,name=Any iOS Device" -target "x86_64-apple-ios16.4-simulator"

# Generating api_dump
echo "📋 Generating api_dump"
xcrun swift-api-digester -dump-sdk -module Adyen -o api_dump.json -I .build/Build/Products/Debug-iphonesimulator -sdk "`xcrun --sdk iphonesimulator --show-sdk-path`" -target "arm64-apple-ios17.2-simulator"

echo "✅ Success"
