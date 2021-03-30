#!/bin/bash

set -e # Any subsequent(*) commands which fail will cause the shell script to exit immediately

PROJECT_NAME=TempProject

rm -rf $PROJECT_NAME

mkdir -p $PROJECT_NAME && cd $PROJECT_NAME

# Create a new Xcode project.
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
  UITests:
    type: bundle.ui-testing
    platform: iOS
    sources: UITests
  UnitTests:
    type: bundle.unit-test
    platform: iOS
    sources: UnitTests
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

cp "../Tests/AdyenTests/Adyen Tests/UI/DropIn/DropInTests.swift" UITests/DropInTests.swift
cp "../Tests/AdyenTests/Adyen Tests/Assets/AssetsAccessTests.swift" UnitTests/AssetsAccessTests.swift
cp -a "../Demo/Common" Source/
cp -a "../Demo/UIKit" Source/
cp "../Demo/Configuration.swift" Source/Configuration.swift

xcodegen generate

# Create a Podfile with our pod as dependency.
echo "platform :ios, '11.0'

target '$PROJECT_NAME' do
  use_frameworks!

  pod 'Adyen', :path => '../'
  pod 'Adyen/WeChatPay', :path => '../'
  pod 'Adyen/SwiftUI', :path => '../'

  target 'UnitTests' do
        inherit! :search_paths
  end

  target 'UITests' do
        inherit! :search_paths
  end
end
" >> Podfile

# Install the pods.
pod install

# Run tests
echo '############# Run tests ###############'
xcodebuild build test -scheme App -workspace $PROJECT_NAME.xcworkspace -destination 'name=iPhone 11' | xcpretty && exit ${PIPESTATUS[0]}

# Archive for generic iOS device
echo '############# Archive for generic iOS device ###############'
xcodebuild archive -scheme App -workspace $PROJECT_NAME.xcworkspace -destination 'generic/platform=iOS' | xcpretty && exit ${PIPESTATUS[0]}

# Build for generic iOS device
echo '############# Build for generic iOS device ###############'
xcodebuild clean build -scheme App -workspace $PROJECT_NAME.xcworkspace -destination 'generic/platform=iOS' | xcpretty && exit ${PIPESTATUS[0]}

# Archive for x86_64 simulator
echo '############# Archive for simulator ###############'
xcodebuild archive -scheme App -workspace $PROJECT_NAME.xcworkspace -destination 'generic/platform=iOS Simulator' | xcpretty && exit ${PIPESTATUS[0]}

# Build for x86_64 simulator
echo '############# Build for simulator ###############'
xcodebuild clean build -scheme App -workspace $PROJECT_NAME.xcworkspace -destination 'generic/platform=iOS Simulator' | xcpretty && exit ${PIPESTATUS[0]}

# Clean up.
cd ../
rm -rf $PROJECT_NAME
