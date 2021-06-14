#!/bin/bash

set -e # Any subsequent(*) commands which fail will cause the shell script to exit immediately

function echo_header {
  echo " "
  echo "#############   $1   ###############"
}

PROJECT_NAME=TempProject

echo_header "Clean up $PROJECT_NAME"
rm -rf $PROJECT_NAME
mkdir -p $PROJECT_NAME && cd $PROJECT_NAME

echo_header "Setup Carthage"
CWD=$(pwd)
CURRENT_COMMIT=$(git rev-parse HEAD)

echo "git \"file://$CWD/../\" \"$CURRENT_COMMIT\"" > Cartfile
../Scripts/carthage.sh update --use-xcframeworks


echo_header "Create a new Xcode project."
echo "
name: $PROJECT_NAME
targets:
  $PROJECT_NAME:
    type: application
    platform: iOS
    sources: Source
    testTargets: [UITests,UnitTests]
    settings:
      base:
        INFOPLIST_FILE: Source/UIKit/Info.plist
        PRODUCT_BUNDLE_IDENTIFIER: com.adyen.$PROJECT_NAME
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
  UITests:
    type: bundle.ui-testing
    platform: iOS
    sources: UITests
  UnitTests:
    type: bundle.unit-test
    platform: iOS
    sources: UnitTests
    dependencies:
      - framework: Carthage/Build/Adyen.xcframework
      - framework: Carthage/Build/AdyenActions.xcframework
      - framework: Carthage/Build/AdyenCard.xcframework
schemes:
  App:
    build:
      targets:
        $PROJECT_NAME: all
        UITests: [test]
        UnitTests: [test]
    test:
      commandLineArguments: "-UITests"
      targets:
        - UITests
        - UnitTests

" > project.yml

mkdir -p UITests
mkdir -p UnitTests
mkdir -p Source
cp "../Tests/AdyenTests/Adyen Tests/DropIn/DropInTests.swift" UITests/DropInTests.swift
cp "../Tests/AdyenTests/Adyen Tests/Components/Dummy.swift" UITests/Dummy.swift
cp "../Tests/AdyenTests/Adyen Tests/Assets/AssetsAccessTests.swift" UnitTests/AssetsAccessTests.swift
cp -a "../Demo/Common" Source/
cp -a "../Demo/UIKit" Source/
cp "../Demo/Configuration.swift" Source/Configuration.swift

xcodegen generate

echo_header "Run Tests"
xcodebuild build test -project $PROJECT_NAME.xcodeproj -scheme App -destination "name=iPhone 11" | xcpretty && exit ${PIPESTATUS[0]}

echo_header "Clean up"
cd ../
rm -rf $PROJECT_NAME
