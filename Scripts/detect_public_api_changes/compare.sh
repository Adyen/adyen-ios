#!/bin/bash

BRANCH=$1
REPO=$2
TARGET="x86_64-apple-ios17.4-simulator"
SDK="`xcrun --sdk iphonesimulator --show-sdk-path`"
MODULE_NAMES=("Adyen" "AdyenDropIn" "AdyenActions" "AdyenCard" "AdyenEncryption" "AdyenComponents" "AdyenSession" "AdyenWeChatPay" "AdyenCashAppPay" "AdyenTwint" "AdyenDelegatedAuthentication")
COMPARISON_VERSION_DIR_NAME="comparison_version_$BRANCH"
DERIVED_DATA_PATH=".build"
SDK_DUMP_INPUT_PATH="$DERIVED_DATA_PATH/Build/Products/Debug-iphonesimulator"

echo "Branch: " $BRANCH
echo "Repo:   " $REPO
echo "Target: " $TARGET
echo "Dir:    " $COMPARISON_VERSION_DIR_NAME

echo "Modules:"
for MODULE in ${MODULE_NAMES[@]}
do
    echo "-" $MODULE
done

rm -rf .build
rm -rf comparison_version

function cleanup() {
    rm -rf .build
    rm -rf $COMPARISON_VERSION_DIR_NAME
    mv Adyen.xcode_proj Adyen.xcodeproj
}

function setupComparisonRepo() {
    rm -rf $COMPARISON_VERSION_DIR_NAME
    mkdir $COMPARISON_VERSION_DIR_NAME
    cd $COMPARISON_VERSION_DIR_NAME
    git clone -b $BRANCH $REPO
    
    cd adyen-ios
    ../../Scripts/detect_public_api_changes/update_package_file.swift Package.swift "AdyenAllTargets"
    mv Adyen.xcodeproj Adyen.xcode_proj # We have to obscure the project file so `xcodebuild` uses the Package.swift to build the module
}

trap cleanup EXIT

mv Adyen.xcodeproj Adyen.xcode_proj
./Scripts/detect_public_api_changes/update_package_file.swift Package.swift "AdyenAllTargets"

echo "↘️  Checking out comparison version"
setupComparisonRepo # We're now in the comparison repository directory

echo "🛠️  Building 'AdyenAllTargets' comparison project"
xcodebuild -derivedDataPath $DERIVED_DATA_PATH -sdk $SDK -scheme "AdyenAllTargets" -destination "platform=iOS,name=Any iOS Device" -target $TARGET -quiet
cd ../..
echo "🛠️  Building 'AdyenAllTargets' updated project"
xcodebuild -derivedDataPath $DERIVED_DATA_PATH -sdk $SDK -scheme "AdyenAllTargets" -destination "platform=iOS,name=Any iOS Device" -target $TARGET -quiet

echo "👷 Building & Diffing"
for MODULE in ${MODULE_NAMES[@]}
do

cd $COMPARISON_VERSION_DIR_NAME/adyen-ios

echo "📋 [$MODULE] Generating comparison api_dump"
xcrun swift-api-digester -dump-sdk -module $MODULE -o ../../api_dump_comparison.json -I $SDK_DUMP_INPUT_PATH -sdk $SDK -target $TARGET

cd ../..

echo "📋 [$MODULE] Generating new api_dump"
xcrun swift-api-digester -dump-sdk -module $MODULE -o api_dump.json -I $SDK_DUMP_INPUT_PATH -sdk $SDK -target $TARGET

echo "🕵️  [$MODULE] Diffing"
./diff.swift api_dump.json api_dump_comparison.json $MODULE

# Reset and move into comparison dir again for the next iteration
rm api_dump.json
rm api_dump_comparison.json

done
