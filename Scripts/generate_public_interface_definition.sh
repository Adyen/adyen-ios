#!/bin/bash

BRANCH=$1
REPO=$2
TARGET="x86_64-apple-ios17.4-simulator"
SDK="`xcrun --sdk iphonesimulator --show-sdk-path`"
MODULE=$3 #"Adyen"
COMPARISON_VERSION_DIR_NAME="comparison_version_$BRANCH"

echo "Branch: " $BRANCH
echo "Repo:   " $REPO
echo "Module: " $MODULE
echo "Target: " $TARGET
echo "Dir:    " $COMPARISON_VERSION_DIR_NAME

rm -rf .build
mv Adyen.xcodeproj Adyen.xcode_proj
rm -rf comparison_version

function cleanup() {
    rm -rf .build
    # rm -rf $COMPARISON_VERSION_DIR_NAME
    mv Adyen.xcode_proj Adyen.xcodeproj
}

trap cleanup EXIT

echo "🗂️  Changed files"

git diff --name-only $(git rev-parse "$BRANCH")

# TODO: Compile a list of changed modules from the git diff
# TODO: Generate a Package.swift target that contains all modules
# TODO: Build each (updated + comparison) project once
# TODO: Generate an sdk dump from every module that had changes

echo "↘️  Checking out comparison version"

# If the directory already exists we just navigate into it and run the commands
if [ ! -d "$COMPARISON_VERSION_DIR_NAME" ];
then
  mkdir $COMPARISON_VERSION_DIR_NAME
  cd $COMPARISON_VERSION_DIR_NAME
  git clone -b $BRANCH $REPO
  cd adyen-ios
  mv Adyen.xcodeproj Adyen.xcode_proj
else
  cd $COMPARISON_VERSION_DIR_NAME
  cd adyen-ios
  mv Adyen.xcodeproj Adyen.xcode_proj
fi

echo "👷 Building comparison project"
xcodebuild -derivedDataPath .build -sdk $SDK -scheme $MODULE -destination "platform=iOS,name=Any iOS Device" -target $TARGET -quiet

echo "📋 Generating comparison api_dump"
xcrun swift-api-digester -dump-sdk -module $MODULE -o ../../api_dump_comparison.json -I .build/Build/Products/Debug-iphonesimulator -sdk $SDK -target $TARGET

cd ../..

# Building project in `.build` directory
echo "👷 Building updated project"
xcodebuild -derivedDataPath .build -sdk $SDK -scheme $MODULE -destination "platform=iOS,name=Any iOS Device" -target $TARGET -quiet

# Generating api_dump
echo "📋 Generating new api_dump"
xcrun swift-api-digester -dump-sdk -module $MODULE -o api_dump.json -I .build/Build/Products/Debug-iphonesimulator -sdk $SDK -target $TARGET
