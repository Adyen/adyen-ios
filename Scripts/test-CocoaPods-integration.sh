#!/bin/bash

function print_help {
  echo "Test CocoaPods Integration"
  echo " "
  echo "test-CocoaPods-integration [-w]"
  echo " "
  echo "options:"
  echo "-w, --exclude-wechat      exclude wechat module"
}

set -e # Any subsequent(*) commands which fail will cause the shell script to exit immediately

INCLUDE_WECHAT=true

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      print_help
      exit 0
      ;;
    -w|--include-wechat)
      INCLUDE_WECHAT=false
      shift
      ;;
  esac
done

PROJECT_NAME=TempProject

function clean_up {
  cd ../
  rm -rf $PROJECT_NAME
  echo "exited"
}

# Delete the temp folder if the script exited with error.
trap "clean_up" 0 1 2 3 6

rm -rf $PROJECT_NAME

mkdir -p $PROJECT_NAME && cd $PROJECT_NAME

echo "
name: $PROJECT_NAME
targets:
  $PROJECT_NAME:
    type: application
    platform: iOS
    sources: Source
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.adyen.$PROJECT_NAME
  Tests:
    type: bundle.ui-testing
    platform: iOS
    sources: Tests
schemes:
  TempProject-Package:
    build:
      targets:
        $PROJECT_NAME: all
        Tests: [tests]
    test:
      targets:
        - Tests
" > project.yml

mkdir -p Source

echo "
import Foundation
import Adyen
@main
class EmptyClass {static func main() {}}
"  > Source/EmptyClass.swift

mkdir -p Tests

xcodegen generate

# Create a Podfile with our pod as dependency.

if [ "$INCLUDE_WECHAT" == false ]
then
  echo "platform :ios, '12.0'

  target '$PROJECT_NAME' do
    use_frameworks!

    pod 'Adyen', :path => '../'
    pod 'Adyen/Session', :path => '../'
    pod 'Adyen/SwiftUI', :path => '../'
    pod 'Adyen/DelegatedAuthentication', :path => '../'
    pod 'Adyen/CashAppPay', :path => '../'
    pod 'Adyen/AdyenTwint', :path => '../'
  end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = \"\"
            config.build_settings['CODE_SIGNING_REQUIRED'] = \"NO\"
            config.build_settings['CODE_SIGNING_ALLOWED'] = \"NO\"
        end
    end
   end
  " >> Podfile
else
  echo "platform :ios, '12.0'

  target '$PROJECT_NAME' do
    use_frameworks!

    pod 'Adyen', :path => '../'
    pod 'Adyen/WeChatPay', :path => '../'
    pod 'Adyen/SwiftUI', :path => '../'
    pod 'AdyenAuthentication'
    pod 'Adyen/CashAppPay', :path => '../'
    pod 'Adyen/AdyenTwint', :path => '../'
  end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = \"\"
            config.build_settings['CODE_SIGNING_REQUIRED'] = \"NO\"
            config.build_settings['CODE_SIGNING_ALLOWED'] = \"NO\"
        end
    end
  end
  " >> Podfile
fi

# Install the pods.
pod install

# Archive for generic iOS device
echo '############# Archive for generic iOS device ###############'
xcodebuild -quiet archive -scheme TempProject-Package -workspace TempProject.xcworkspace -destination 'generic/platform=iOS' CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO GENERATE_INFOPLIST_FILE=YES 

# Build for generic iOS device
echo '############# Build for generic iOS device ###############'
xcodebuild -quiet clean build -scheme TempProject-Package -workspace TempProject.xcworkspace -destination 'generic/platform=iOS' CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO GENERATE_INFOPLIST_FILE=YES 

# Archive for x86_64 simulator
echo '############# Archive for simulator ###############'
xcodebuild -quiet archive -scheme TempProject-Package -workspace TempProject.xcworkspace -destination 'generic/platform=iOS Simulator' CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO GENERATE_INFOPLIST_FILE=YES 

# Build for x86_64 simulator
echo '############# Build for simulator ###############'
xcodebuild -quiet clean build -scheme TempProject-Package -workspace TempProject.xcworkspace -destination 'generic/platform=iOS Simulator' CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO GENERATE_INFOPLIST_FILE=YES 
