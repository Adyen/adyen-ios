#!/bin/bash

echo "Branch: " $1
echo "Repo:   " $2

rm -rf .build
mv Adyen.xcodeproj Adyen.xcode_proj
rm -rf comparison_version

function cleanup() {
    rm -rf .build
    rm -rf comparison_version
    mv Adyen.xcode_proj Adyen.xcodeproj
}

trap cleanup EXIT

echo "↘️  Checking out comparison version"
mkdir comparison_version
cd comparison_version
git clone -b $1 $2
cd adyen-ios
mv Adyen.xcodeproj Adyen.xcode_proj

echo "👷 Building comparison project"
xcodebuild -derivedDataPath .build -sdk "`xcrun --sdk iphonesimulator --show-sdk-path`" -scheme "Adyen" -destination "platform=iOS,name=Any iOS Device" -target "x86_64-apple-ios16.4-simulator" -quiet

echo "📋 Generating comparison api_dump"
xcrun swift-api-digester -dump-sdk -module Adyen -o ../../api_dump_comparison.json -I .build/Build/Products/Debug-iphonesimulator -sdk "`xcrun --sdk iphonesimulator --show-sdk-path`" -target "arm64-apple-ios17.2-simulator"

cd ../..

# Building project in `.build` directory
echo "👷 Building updated project"
xcodebuild -derivedDataPath .build -sdk "`xcrun --sdk iphonesimulator --show-sdk-path`" -scheme "Adyen" -destination "platform=iOS,name=Any iOS Device" -target "x86_64-apple-ios16.4-simulator" -quiet

# Generating api_dump
echo "📋 Generating new api_dump"
xcrun swift-api-digester -dump-sdk -module Adyen -o api_dump.json -I .build/Build/Products/Debug-iphonesimulator -sdk "`xcrun --sdk iphonesimulator --show-sdk-path`" -target "arm64-apple-ios17.2-simulator"

#echo "🔀 Comparing"

# echo "- diff"
# diff api_dump_comparison.json api_dump.json

#echo "- swift-api-digester -diagnose-sdk"
# This command does not take @_spi into account unfortunately (It works well with changing from public to private or add new func/var/objects)
# xcrun swift-api-digester -diagnose-sdk -module Adyen -o api_diff -use-interface-for-module Adyen -abi -BI ./last_release/adyen-ios/.build/Build/Products/Debug-iphonesimulator -I .build/Build/Products/Debug-iphonesimulator -bsdk "`xcrun --sdk iphonesimulator --show-sdk-path`" -sdk "`xcrun --sdk iphonesimulator --show-sdk-path`" -target "arm64-apple-ios17.2-simulator"
# cat api_diff

# This command also does not take @_spi into account (Same as swift-api-digester -diagnose-sdk basically but running on the json files)
# xcrun swift-api-digester -diagnose-sdk --input-paths api_dump_comparison.json -input-paths api_dump.json
