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
  ../Scripts/carthage.sh update --use-xcframeworks
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
      - framework: Carthage/Build/AdyenNetworking.xcframework
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
cp "../Tests/AdyenTests/Adyen Tests/DropIn/DropInTests.swift" Tests/DropInTests.swift
cp "../Tests/AdyenTests/Adyen Tests/DropIn/XCTestCaseExtensions.swift" Tests/XCTestCaseExtensions.swift
cp "../Tests/AdyenTests/Adyen Tests/Components/Dummy.swift" Tests/Dummy.swift
cp -a "../Demo/Common" Source/
cp -a "../Demo/UIKit" Source/
cp "../Demo/Configuration.swift" Source/Configuration.swift

xcodegen generate

echo_header "Run Tests"
xcodebuild build test -project $PROJECT_NAME.xcodeproj -scheme App -destination "name=iPhone 13" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO | xcpretty && exit ${PIPESTATUS[0]}

if [ "$NEED_CLEANUP" == true ]
then
  echo_header "Clean up"
  cd ../
  rm -rf $PROJECT_NAME
fi
