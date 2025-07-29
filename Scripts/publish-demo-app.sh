#!/bin/bash
set -euo pipefail

BUILD_PATH=Build-Temp

echo "📦 Cleaning..."
xcodebuild clean -project Adyen.xcodeproj \
 -scheme AdyenUIHost \
 -destination="generic/platform=iOS" \
 -sdk iphoneos \
 -configuration Release \
 -skipPackagePluginValidation

mkdir -p $BUILD_PATH

echo "📦 Archiving..."
xcodebuild archive -project Adyen.xcodeproj \
 -scheme AdyenUIHost \
 -destination="generic/platform=iOS" \
 -sdk iphoneos \
 -configuration Release \
 -archivePath $BUILD_PATH/AdyenUIHost.xcarchive \
 -allowProvisioningUpdates \
 -skipPackagePluginValidation

echo "🔍 Checking available identities..."
security find-identity -v -p codesigning

echo "📦 Exporting IPA with manual signing..."
xcodebuild -exportArchive \
 -archivePath $BUILD_PATH/AdyenUIHost.xcarchive \
 -exportOptionsPlist exportOptions.plist \
 -exportPath $BUILD_PATH \
 -allowProvisioningUpdates \
 -skipPackagePluginValidation

echo "☁️ Uploading to App Store Connect..."
xcrun altool --upload-app -f $BUILD_PATH/AdyenUIHost.ipa -u $1 -p $2 --type ios
