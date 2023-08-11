#!/bin/bash

function echo_group {
  echo " "
  echo "::endgroup::"
  echo "::group:: $1"
}

function print_help {
  echo "Test CocoaPods Integration"
  echo " "
  echo "test-CocoaPods-integration [-w]"
  echo " "
  echo "options:"
  echo "-w, --exclude-wechat      exclude wechat module"
  echo "-c, --no-clean            ignore cleanup"
  echo "-p, --project             specify project name"
}

set -e # Any subsequent(*) commands which fail will cause the shell script to exit immediately

INCLUDE_WECHAT=true
NEED_CLEANUP=true
PROJECT_NAME=TempProject

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      print_help
      exit 0
      ;;
    -c|--no-clean)
      NEED_CLEANUP=false
      shift
      ;;
    -w|--include-wechat)
      INCLUDE_WECHAT=false
      shift
      ;;
    -p|--project)
      PROJECT_NAME="$1"
      shift
      ;;
  esac
done

if [ "$NEED_CLEANUP" == true ]
then
  rm -rf $PROJECT_NAME
  mkdir -p $PROJECT_NAME && cd $PROJECT_NAME
else
  cd $PROJECT_NAME
fi

# Create the Package.swift.
echo_group "::group::Generate Project"
echo "
name: $PROJECT_NAME
targets:
  $PROJECT_NAME:
    type: application
    platform: iOS
    sources: Source
    testTargets: Tests
    settings:
      base:
        INFOPLIST_FILE: Source/UIKit/Info.plist
        PRODUCT_BUNDLE_IDENTIFIER: com.adyen.$PROJECT_NAME
  Tests:
    type: bundle.ui-testing
    platform: iOS
    sources: Tests
schemes:
  App:
    build:
      targets:
        $PROJECT_NAME: all
        Tests: [tests]
    test:
      commandLineArguments: "-UITests"
      targets:
        - Tests
" > project.yml

mkdir -p Tests
mkdir -p Source
cp "../Tests/DropIn Tests/DropInTests.swift" Tests/DropInTests.swift
cp "../Tests/Card Tests/3DS2 Component/ThreeDS2PlusDACoreActionHandlerTests.swift" Tests/ThreeDS2PlusDACoreActionHandlerTests.swift
cp "../Tests/Card Tests/3DS2 Component/AnyADYServiceMock.swift" Tests/AnyADYServiceMock.swift
cp "../Tests/Card Tests/3DS2 Component/AuthenticationServiceMock.swift" Tests/AuthenticationServiceMock.swift
cp "../Tests/Card Tests/3DS2 Component/ThreeDSResultExtension.swift" Tests/ThreeDSResultExtension.swift
cp "../Tests/Helpers/XCTestCaseExtensions.swift" Tests/XCTestCaseExtensions.swift
cp "../Tests/DummyData/Dummy.swift" Tests/Dummy.swift
cp -a "../Demo/Common" Source/
cp -a "../Demo/UIKit" Source/
cp "../Demo/Configuration.swift" Source/Configuration.swift

xcodegen generate

# Create a Podfile with our pod as dependency.
echo_group "Pod Install"
if [ "$INCLUDE_WECHAT" == false ]
then
  echo "platform :ios, '11.0'

  target '$PROJECT_NAME' do
    use_frameworks!

    pod 'Adyen', :path => '../'
    pod 'Adyen/Session', :path => '../'
    pod 'Adyen/SwiftUI', :path => '../'
    pod 'AdyenAuthentication'
    pod 'Adyen/CashAppPay', :path => '../'
  end

  " >> Podfile
else
  echo "platform :ios, '11.0'

  target '$PROJECT_NAME' do
    use_frameworks!

    pod 'Adyen', :path => '../'
    pod 'Adyen/WeChatPay', :path => '../'
    pod 'Adyen/SwiftUI', :path => '../'
    pod 'AdyenAuthentication'
    pod 'Adyen/CashAppPay', :path => '../'
  end

  " >> Podfile
fi

pod install

echo_group "Archive for generic iOS device"
xcodebuild clean build archive \
  -scheme App \
  -workspace $PROJECT_NAME.xcworkspace \
  -destination 'generic/platform=iOS' \
  | xcpretty && exit ${PIPESTATUS[0]}

echo_group "Archive for for x86_64 simulator"
xcodebuild clean build archive \
  -scheme App \
  -workspace $PROJECT_NAME.xcworkspace \
  -destination 'generic/platform=iOS Simulator' \
  | xcpretty && exit ${PIPESTATUS[0]}
  
echo_group "Run Tests"
xcodebuild test \
  -scheme App \
  -workspace $PROJECT_NAME.xcworkspace \
  -destination "name=iPhone 14" \
  -skipPackagePluginValidation \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  | xcpretty && exit ${PIPESTATUS[0]}

echo "::endgroup::"
