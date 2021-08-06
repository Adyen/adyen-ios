#!/bin/bash

set -e # Any subsequent(*) commands which fail will cause the shell script to exit immediately

function echo_header {
  echo " "
  echo "===   $1"
}

function print_help {
  echo "Test Swift Package Integration"
  echo " "
  echo "test-SPM-integration.sh [project name] [arguments]"
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
else
  cd $PROJECT_NAME
fi

echo_header "Generate Project"
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
    settings:
      base:
        INFOPLIST_FILE: Source/Info.plist
        PRODUCT_BUNDLE_IDENTIFIER: com.adyen.$PROJECT_NAME
        DEVELOPMENT_TEAM: Adyen B.V.
    dependencies:
      - package: Adyen
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
cp "../Tests/AdyenTests/Adyen Tests/Components/Dummy.swift" Tests/Dummy.swift
cp -a "../Demo/Common" Source/
cp -a "../Demo/UIKit" Source/
cp "../Demo/Configuration.swift" Source/Configuration.swift

xcodegen generate

# Build for generic iOS device
echo '############# Build for generic iOS device ###############'
xcodebuild build -scheme App -destination 'generic/platform=iOS' | xcpretty && exit ${PIPESTATUS[0]}

# Archive for x86_64 simulator
echo '############# Archive for x86_64 simulator ###############'
xcodebuild archive -scheme App -destination 'generic/platform=iOS Simulator' ARCHS=x86_64 -allowProvisioningUpdates | xcpretty && exit ${PIPESTATUS[0]}

# Build for x86_64 simulator
echo '############# Build for x86_64 simulator ###############'
xcodebuild build -scheme App -destination 'generic/platform=iOS Simulator' ARCHS=x86_64 | xcpretty && exit ${PIPESTATUS[0]}

echo_header "Run Tests"
xcodebuild build test -project $PROJECT_NAME.xcodeproj -scheme App -destination "name=iPhone 11" | xcpretty && exit ${PIPESTATUS[0]}

if [ "$NEED_CLEANUP" == true ]
then
  echo_header "Clean up"
  cd ../
  rm -rf $PROJECT_NAME
fi
