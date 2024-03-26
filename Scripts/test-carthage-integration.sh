#!/bin/bash

set -e # Any subsequent(*) commands which fail will cause the shell script to exit immediately

function echo_header {
  echo " "
  echo "===   $1"
}

function print_help {
  echo "Test Carthage Integration"
  echo " "
  echo "test-carthage-integration [project name] [arguments]"
  echo " "
  echo "options:"
  echo "-h, --help                show brief help"
  echo "-c, --no-clean            ignore cleanup"
}

PROJECT_NAME=TempProject
NEED_CLEANUP=true

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
    -p|--project)
      PROJECT_NAME="$1"
      shift
      ;;
  esac
done

if [ "$NEED_CLEANUP" == true ]
then
  echo_header "Clean up $PROJECT_NAME"
  rm -rf $PROJECT_NAME
  mkdir -p $PROJECT_NAME && cd $PROJECT_NAME

  echo_header "Setup Carthage"
  CWD=$(pwd)
  CURRENT_COMMIT=$(git rev-parse HEAD)

  echo "git \"file://$CWD/../\" \"$CURRENT_COMMIT\"" > Cartfile
  carthage update --use-xcframeworks --configuration Debug
else
  cd $PROJECT_NAME
fi

echo_header "Generate Project"
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
      - framework: Carthage/Build/AdyenSession.xcframework
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
      - framework: Carthage/Build/AdyenDelegatedAuthentication.xcframework
        embed: true
        codeSign: true
      - framework: Carthage/Checkouts/adyen-3ds2-ios/XCFramework/Dynamic/Adyen3DS2.xcframework
        embed: true
        codeSign: true
      - framework: Carthage/Build/AdyenNetworking.xcframework
        embed: true
        codeSign: true
      - framework: Carthage/Build/AdyenAuthentication.xcframework
        embed: true
        codeSign: true
      - framework: Carthage/Build/AdyenSwiftUI.xcframework
        embed: true
        codeSign: true
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
cp "../Tests/DropIn Tests/DropInDelegateMock.swift" Tests/DropInDelegateMock.swift
cp "../Tests/Card Tests/Mocks/OpenExternalAppDetector+Mock.swift" Tests/OpenExternalAppDetector+Mock.swift
cp "../Tests/Card Tests/3DS2 Component/ThreeDS2PlusDACoreActionHandlerTests.swift" Tests/ThreeDS2PlusDACoreActionHandlerTests.swift
cp "../Tests/Card Tests/3DS2 Component/ThreeDS2PlusDACoreActionHandlerTests+Constants.swift" Tests/ThreeDS2PlusDACoreActionHandlerTests+Constants.swift
cp "../Tests/Card Tests/3DS2 Component/AnyADYServiceMock.swift" Tests/AnyADYServiceMock.swift
cp "../Tests/Card Tests/3DS2 Component/AuthenticationServiceMock.swift" Tests/AuthenticationServiceMock.swift
cp "../Tests/Card Tests/3DS2 Component/ThreeDSResultExtension.swift" Tests/ThreeDSResultExtension.swift
cp "../Tests/Helpers/XCTestCase+RootViewController.swift" Tests/XCTestCase+RootViewController.swift
cp "../Tests/Helpers/XCTestCase+Wait.swift" Tests/XCTestCase+Wait.swift
cp "../Tests/Helpers/UIViewController+Search.swift" Tests/UIViewController+Search.swift
cp "../Tests/Helpers/PaymentMethods+Equatable.swift" Tests/PaymentMethods+Equatable.swift
cp "../Tests/Adyen Tests/Analytics/AnalyticsProviderMock.swift" Tests/AnalyticsProviderMock.swift
cp "../Tests/DummyData/Dummy.swift" Tests/Dummy.swift
cp "../Demo/Common/Utils/APIClientMock.swift" Tests/APIClientMock.swift
cp "../Tests/Adyen Tests/Mocks/ImageLoaderMock.swift" Tests/ImageLoaderMock.swift
cp -a "../Demo/Common" Source/
cp -a "../Demo/UIKit" Source/
cp "../Demo/Configuration.swift" Source/Configuration.swift

xcodegen generate

echo_header "Run Tests"
xcodebuild build test -project $PROJECT_NAME.xcodeproj -scheme App -destination "name=iPhone 11" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO | xcpretty && exit ${PIPESTATUS[0]}

if [ "$NEED_CLEANUP" == true ]
then
  echo_header "Clean up"
  cd ../
  rm -rf $PROJECT_NAME
fi
