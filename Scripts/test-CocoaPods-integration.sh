#!/bin/bash

# Any subsequent(*) commands which fail will cause the shell script to exit immediately
set -eo pipefail

function print_help {
  echo "Test CocoaPods Integration"
  echo " "
  echo "test-CocoaPods-integration [-w]"
  echo " "
  echo "options:"
  echo "-w, --exclude-wechat      exclude wechat module"
  echo "-t, --team                set DEVELOPMENT_TEAM to all bundle modules"
}

function echo_header {
  echo " "
  echo "############# $1 #############"
}

INCLUDE_WECHAT=false
PROJECT_NAME=TempProject

while [[ $# -ne 0 ]]; do
  case $1 in
    -h|--help)
      print_help
      exit 0
      ;;
    -w|--include-wechat)
      INCLUDE_WECHAT=true
      shift
      ;;
    -t|--team)
      DEVELOPMENT_TEAM="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done


function clean_up {
  cd ../
  rm -rf $PROJECT_NAME
  echo_header 'Clean up and exit'
}

# Delete the temp folder if the script exited with error.
trap "clean_up" 0 1 2 3 6

rm -rf $PROJECT_NAME

mkdir -p $PROJECT_NAME && cd $PROJECT_NAME

echo_header 'Create a new Xcode project'
swift package init

# Create the Package.swift.
echo "// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: \"TempProject\",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: \"TempProject\",
            targets: [\"TempProject\"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: \"TempProject\",
            dependencies: []),
        .testTarget(
            name: \"TempProjectTests\",
            dependencies: [\"TempProject\"]),
    ]
)

" > Package.swift

swift package update
swift package generate-xcodeproj

# Create a Podfile with our pod as dependency.

echo "platform :ios, '11.0'

target '$PROJECT_NAME' do
  use_frameworks!

  pod 'Adyen', :path => '../'
  pod 'Adyen/Session', :path => '../'
  pod 'Adyen/SwiftUI', :path => '../'" >> Podfile

# Add dependency
if [ "$INCLUDE_WECHAT" == false ]; then
  echo "end" >> Podfile
else
  echo "  pod 'Adyen/WeChatPay', :path => '../'" >> Podfile
  echo "end" >> Podfile
fi

# Add fix to https://github.com/CocoaPods/CocoaPods/issues/11402#issuecomment-1149585364
if [ ! -z "$DEVELOPMENT_TEAM" ]; then
  echo "" >> Podfile
  echo "post_install do |installer|" >> Podfile
  echo "  installer.generated_projects.each do |project|" >> Podfile
  echo "    project.targets.each do |target|" >> Podfile
  echo "        target.build_configurations.each do |config|" >> Podfile
  echo "            config.build_settings[\"DEVELOPMENT_TEAM\"] = \"$DEVELOPMENT_TEAM\"" >> Podfile
  echo "        end" >> Podfile
  echo "    end" >> Podfile
  echo "  end" >> Podfile
  echo "end" >> Podfile
fi

# Install the pods.
pod install

# Build and Archive for generic iOS device
echo_header 'Build for generic iOS device'
xcodebuild clean build archive -scheme TempProject-Package -workspace TempProject.xcworkspace -destination 'generic/platform=iOS' | xcpretty --utf --color

# Build and Archive for x86_64 simulator
echo_header 'Build for simulator'
xcodebuild clean build archive -scheme TempProject-Package -workspace TempProject.xcworkspace -destination 'generic/platform=iOS Simulator' | xcpretty --utf --color
