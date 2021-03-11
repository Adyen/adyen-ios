#!/bin/bash

set -e # Any subsequent(*) commands which fail will cause the shell script to exit immediately

function echo_header {
  echo "==   $1   =="
}

PROJECT_NAME=TempProject

echo_header "Clean up"
rm -rf $PROJECT_NAME

mkdir -p $PROJECT_NAME && cd $PROJECT_NAME

echo_header "Setup Carthage"
CWD=$(pwd)
CURRENT_COMMIT=$(git rev-parse HEAD)

echo "git \"file://$CWD/../\" \"$CURRENT_COMMIT\"" > Cartfile

../Scripts/carthage.sh update --use-xcframeworks

echo_header "Generate Project"
echo "
name: $PROJECT_NAME
targets:
  $PROJECT_NAME:
    type: framework
    platform: iOS
    dependencies:
      - framework: Carthage/Build/Adyen.xcframework
        embed: true
        codeSign: true
      - framework: Carthage/Build/AdyenActions.xcframework
        embed: true
        codeSign: true
      - framework: Carthage/Build/AdyenCard.xcframework
        embed: true
        codeSign: true
      - framework: Carthage/Build/AdyenComponents.xcframework
        embed: true
        codeSign: true
      - framework: Carthage/Build/AdyenDropIn.xcframework
        embed: true
        codeSign: true
      - framework: Carthage/Build/AdyenEncryption.xcframework
        embed: true
        codeSign: true
      - framework: Carthage/Build/AdyenWeChatPay.xcframework
        embed: true
        codeSign: true
      - framework: Carthage/Checkouts/adyen-3ds2-ios/XCFramework/Dynamic/Adyen3DS2.xcframework
        embed: true
        codeSign: true
      - framework: Carthage/Build/AdyenSwiftUI.xcframework
        embed: true
        codeSign: true
  Tests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - Tests/
    dependencies:
      - target: $PROJECT_NAME
" > project.yml

mkdir Tests
cp -a "../Demo/Common" Common
cp -a "../Demo/UIKit" ./
cp "../Demo/Configuration.swift" Configuration.swift
cp "../Tests/AdyenTests/Adyen Tests/UI/DropIn/DropInTests.swift" Tests/DropInTests.swift

xcodegen generate

echo_header "Run Tests"
xcodebuild test -project $PROJECT_NAME.xcodeproj -scheme Tests -destination "name=iPhone 11" | xcpretty && exit ${PIPESTATUS[0]}

echo_header "Clean up"
cd ../
rm -rf $PROJECT_NAME
