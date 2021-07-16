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

echo_header "Create a new Xcode project."
echo "
name: $PROJECT_NAME
packages:
  Adyen:
    path: ../
targets:
  $PROJECT_NAME:
    type: application
    platform: iOS
    sources: Source
    testTargets: [UITests,UnitTests]
    settings:
      PRODUCT_BUNDLE_IDENTIFIER: com.adyen.$PROJECT_NAME
      CURRENT_PROJECT_VERSION: 1
      MARKETING_VERSION: 1
    dependencies:
      - package: Adyen
        product: Adyen
        embed: true
      - package: Adyen
        product: AdyenActions
        embed: true
      - package: Adyen
        product: AdyenComponents
        embed: true
      - package: Adyen
        product: AdyenCard
        embed: true
      - package: Adyen
        product: AdyenDropIn
        embed: true
      - package: Adyen
        product: AdyenEncryption
        embed: true
      - package: Adyen
        product: AdyenWeChatPay
        embed: true
      - package: Adyen
        product: AdyenSwiftUI
        embed: true
  UITests:
    type: bundle.ui-testing
    platform: iOS
    sources: UITests
    dependency: $PROJECT_NAME
  UnitTests:
    type: bundle.unit-test
    platform: iOS
    sources: UnitTests
    dependency: $PROJECT_NAME
schemes:
  App:
    build:
      targets:
        $PROJECT_NAME: all
        UITests: [test]
        UnitTests: [test]
    test:
      commandLineArguments: 
        "-UITests": true
      targets:
        - UITests
        - UnitTests

" > project.yml

mkdir -p UITests
mkdir -p UnitTests
mkdir -p Source

cp "../Tests/AdyenTests/Adyen Tests/DropIn/DropInTests.swift" UITests/DropInTests.swift
cp "../Tests/AdyenTests/Adyen Tests/Components/Dummy.swift" UITests/Dummy.swift
cp -a "../Demo/Common" Source/
cp -a "../Demo/UIKit" Source/
cp "../Demo/Configuration.swift" Source/Configuration.swift

xcodegen generate

echo_header "Run tests"
xcodebuild build test -project $PROJECT_NAME.xcodeproj -scheme App -destination "name=iPhone 11" | xcpretty && exit ${PIPESTATUS[0]}


echo_header "Archive for generic iOS device"
xcodebuild archive -project $PROJECT_NAME.xcodeproj -scheme App -destination 'generic/platform=iOS' | xcpretty && exit ${PIPESTATUS[0]}

echo_header "Build for generic iOS device"
xcodebuild clean build -project $PROJECT_NAME.xcodeproj -scheme App -destination 'generic/platform=iOS' | xcpretty && exit ${PIPESTATUS[0]}

echo_header "Archive for simulator"
xcodebuild archive -project $PROJECT_NAME.xcodeproj -scheme App -destination 'generic/platform=iOS Simulator' | xcpretty && exit ${PIPESTATUS[0]}

echo_header "Build for x86_64 simulator"
xcodebuild clean build -project $PROJECT_NAME.xcodeproj -scheme App -destination 'generic/platform=iOS Simulator' | xcpretty && exit ${PIPESTATUS[0]}

echo_header "Clean up"
cd ../
rm -rf $PROJECT_NAME
