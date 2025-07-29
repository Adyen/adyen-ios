#!/bin/bash

set -euo pipefail

APPLE_ID_USERNAME="$1"
APPLE_APP_SPECIFIC_PASSWORD="$2"
BUILD_NUMBER="$3"

echo "🔧 Building Demo app for distribution..."

xcodebuild clean -scheme AdyenUIHost -workspace Adyen.xcodeproj

xcodebuild archive \
  -workspace Adyen.xcodeproj \
  -scheme AdyenUIHost \
  -configuration Release \
  -archivePath ./Build-Temp/AdyenUIHost.xcarchive \
  -destination "generic/platform=iOS" \
  -allowProvisioningUpdates \
  -allowProvisioningDeviceRegistration \
  -derivedDataPath ./Build-Temp/DerivedData \
  -quiet \
  OTHER_CODE_SIGN_FLAGS="--keychain $RUNNER_TEMP/app-signing.keychain-db" \
  CODE_SIGN_STYLE=Manual \
  DEVELOPMENT_TEAM=$APPLE_DEVELOPMENT_TEAM_ID \
  PRODUCT_BUNDLE_IDENTIFIER=$APP_BUNDLE_ID \
  BUILD_NUMBER=$BUILD_NUMBER

echo "📦 Exporting IPA..."

xcodebuild -exportArchive \
  -archivePath ./Build-Temp/AdyenUIHost.xcarchive \
  -exportPath ./Build-Temp \
  -exportOptionsPlist ./ExportOptions.plist \
  -quiet

echo "☁️ Uploading to App Store Connect..."

xcrun altool --upload-app \
  --type ios \
  --file ./Build-Temp/AdyenUIHost.ipa \
  --username "$APPLE_ID_USERNAME" \
  --password "$APPLE_APP_SPECIFIC_PASSWORD" \
  --output-format xml

echo "✅ Upload complete."
