#!/bin/bash

# Since Jazzy doesn't support generating a single set of documentation
# for multiple modules, we use a temporary Xcode project with CocoaPods.
# CocoaPods turns the different modules into a single module, which
# can then be processed by Jazzy.

PROJECT_NAME=TempProject

mkdir -p $PROJECT_NAME && cd $PROJECT_NAME

# Create a new Xcode project.
swift package init
swift package generate-xcodeproj

# Create a Podfile with our pod as dependency.
echo "
platform :ios, '13.0'

target '$PROJECT_NAME' do
  use_frameworks!

  pod 'Adyen', :path => '../'
  pod 'Adyen/WeChatPay', :path => '../'
  pod 'Adyen/SwiftUI', :path => '../'
end
" >> Podfile

# Install the pods.
pod install

# Run Jazzy from the Pods folder.
cd Pods
jazzy -x USE_SWIFT_RESPONSE_FILE=NO

# Clean up.
cd ../../
rm -rf $PROJECT_NAME
