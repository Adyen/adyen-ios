#!/bin/bash

set -euo pipefail

BUILD_PATH=Build-Temp
APPLE_ID_USERNAME="$1"
APPLE_APP_SPECIFIC_PASSWORD="$2"
XCODE_AUTHENTICATION_KEY_PATH="$3"
BUILD_NUMBER="$4"

echo "🔧 Building Demo app for distribution..."

xcodebuild clean \
    -project Adyen.xcodeproj \
    -scheme AdyenUIHost \
    -destination="generic/platform=iOS" \
    -sdk iphoneos \
    -configuration Release \
    -skipPackagePluginValidation

mkdir -p $BUILD_PATH

xcodebuild archive \
    -project Adyen.xcodeproj \
    -scheme AdyenUIHost \
    -destination="generic/platform=iOS" \
    -sdk iphoneos \
    -configuration Release \
    -archivePath $BUILD_PATH/AdyenUIHost.xcarchive \
    -allowProvisioningUpdates \
    -allowProvisioningDeviceRegistration \
    -derivedDataPath $BUILD_PATH/DerivedData
    -skipPackagePluginValidation \
    -authenticationKeyID $XCODE_AUTHENTICATION_KEY_ID \
    -authenticationKeyIssuerID $XCODE_AUTHENTICATION_KEY_ISSUER_ID \
    -authenticationKeyPath $XCODE_AUTHENTICATION_KEY_PATH \
    -quiet \
    CODE_SIGN_STYLE=Manual \
    BUILD_NUMBER=$BUILD_NUMBER

echo "📦 Exporting IPA..."

xcodebuild -exportArchive \
    -archivePath $BUILD_PATH/AdyenUIHost.xcarchive \
    -exportOptionsPlist exportOptions.plist \
    -exportPath $BUILD_PATH \
    -allowProvisioningUpdates \
    -skipPackagePluginValidation \
    -authenticationKeyID $XCODE_AUTHENTICATION_KEY_ID \
    -authenticationKeyIssuerID $XCODE_AUTHENTICATION_KEY_ISSUER_ID \
    -authenticationKeyPath $3

echo "☁️ Uploading to App Store Connect..."

xcrun altool --upload-app \
  --type ios \
  --file $BUILD_PATH/AdyenUIHost.ipa \
  --username "$APPLE_ID_USERNAME" \
  --password "$APPLE_APP_SPECIFIC_PASSWORD" \
  --output-format xml

echo "✅ Upload complete."