#!/bin/bash

set -e # Any subsequent(*) commands which fail will cause the shell script to exit immediately

PROJECT_NAME=TempProject

echo "==  Clean up =="
rm -rf $PROJECT_NAME

mkdir -p $PROJECT_NAME && cd $PROJECT_NAME

echo "== Create the Cartfile =="
CWD=$(pwd)
CURRENT_COMMIT=$(git rev-parse HEAD)

echo "git \"file://$CWD/../\" \"$CURRENT_COMMIT\"" > Cartfile

../Scripts/carthage.sh update --use-xcframeworks

echo "==   Setup Project =="
echo "
name: $PROJECT_NAME
options:
  findCarthageFrameworks: true
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
  Tests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - Tests/
    dependencies:
      - target: $PROJECT_NAME
" > project.yml

mkdir Tests
mv -v "../Demo/Common" Common
mv -v "../Demo/UIKit" ./
mv "../Demo/Configuration.swift" Configuration.swift
mv "../Tests/AdyenTests/Adyen Tests/UI/DropIn/DropInTests.swift" Tests/DropInTests.swift

xcodegen generate

echo "==   Run Tests =="
xcodebuild test -project $PROJECT_NAME.xcodeproj -scheme Tests -destination "name=iPhone 11" | xcpretty && exit ${PIPESTATUS[0]}

echo "==   Clean up =="
cd ../
rm -rf $PROJECT_NAME
