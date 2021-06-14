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

echo_header "Create a Podfile with our pod as dependency."
echo "platform :ios, '11.0'

target '$PROJECT_NAME' do
  use_frameworks!

  pod 'Adyen', :path => '../'
  pod 'Adyen/WeChatPay', :path => '../'
  pod 'Adyen/SwiftUI', :path => '../'

  target 'UnitTests' do
  end

  target 'UITests' do
  end
end
" >> Podfile

echo_header "Install the pods."
pod install

echo_header "Run tests"
xcodebuild build test -scheme App -workspace $PROJECT_NAME.xcworkspace -destination 'name=iPhone 11' | xcpretty && exit ${PIPESTATUS[0]}

echo_header "Archive for generic iOS device"
xcodebuild archive -scheme App -workspace $PROJECT_NAME.xcworkspace -destination 'generic/platform=iOS' | xcpretty && exit ${PIPESTATUS[0]}

echo_header "Build for generic iOS device"
xcodebuild clean build -scheme App -workspace $PROJECT_NAME.xcworkspace -destination 'generic/platform=iOS' | xcpretty && exit ${PIPESTATUS[0]}

echo_header "Archive for simulator ###############"
xcodebuild archive -scheme App -workspace $PROJECT_NAME.xcworkspace -destination 'generic/platform=iOS Simulator' | xcpretty && exit ${PIPESTATUS[0]}

echo_header "Build for x86_64 simulator"
xcodebuild clean build -scheme App -workspace $PROJECT_NAME.xcworkspace -destination 'generic/platform=iOS Simulator' | xcpretty && exit ${PIPESTATUS[0]}

echo_header "Clean up"
cd ../
rm -rf $PROJECT_NAME
