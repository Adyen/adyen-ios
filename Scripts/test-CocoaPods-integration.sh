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
    testTargets: [UITests]
    settings:
      PRODUCT_BUNDLE_IDENTIFIER: com.adyen.$PROJECT_NAME
      CURRENT_PROJECT_VERSION: 1
      MARKETING_VERSION: 1
  UITests:
    type: bundle.ui-testing
    platform: iOS
    sources: UITests
    dependencies:
      - target: $PROJECT_NAME
schemes:
  App:
    build:
      targets:
        $PROJECT_NAME: all
        UITests: [test]
    test:
      commandLineArguments: 
        "-UITests": true
      targets:
        - UITests

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

echo_header "Create a Podfile with our pod as dependency."
echo "platform :ios, '11.0'

target '$PROJECT_NAME' do
  use_frameworks!

  pod 'Adyen', :path => '../'
  pod 'Adyen/WeChatPay', :path => '../'
  pod 'Adyen/SwiftUI', :path => '../'

  target 'UITests' do
  end
end
" >> Podfile

echo_header "Install the pods."
# pod update
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
