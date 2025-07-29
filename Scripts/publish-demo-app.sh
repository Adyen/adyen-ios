#!/bin/bash
set -euo pipefail

# Constants
BUILD_PATH="Build-Temp"
ARCHIVE_PATH="$BUILD_PATH/AdyenUIHost.xcarchive"
IPA_PATH="$BUILD_PATH/AdyenUIHost.ipa"

# Input arguments
APPLE_ID_USERNAME="${1:-}"
APPLE_APP_SPECIFIC_PASSWORD="${2:-}"
XCODE_AUTHENTICATION_KEY_PATH="${3:-}"

# Required environment variables
: "${XCODE_AUTHENTICATION_KEY_ID:?Environment variable XCODE_AUTHENTICATION_KEY_ID not set}"
: "${XCODE_AUTHENTICATION_KEY_ISSUER_ID:?Environment variable XCODE_AUTHENTICATION_KEY_ISSUER_ID not set}"

# Validate arguments
if [[ -z "$APPLE_ID_USERNAME" || -z "$APPLE_APP_SPECIFIC_PASSWORD" || -z "$XCODE_AUTHENTICATION_KEY_PATH" ]]; then
    echo "Usage: $0 <APPLE_ID_USERNAME> <APPLE_APP_SPECIFIC_PASSWORD> <XCODE_AUTHENTICATION_KEY_PATH>"
    exit 1
fi

echo "🧹 Cleaning project..."
xcodebuild clean -project Adyen.xcodeproj \
  -scheme AdyenUIHost \
  -destination "generic/platform=iOS" \
  -sdk iphoneos \
  -configuration Release \
  -skipPackagePluginValidation

echo "📁 Creating build directory..."
rm -rf "$BUILD_PATH"
mkdir -p "$BUILD_PATH"

echo "📦 Archiving app..."
xcodebuild archive -project Adyen.xcodeproj \
  -scheme AdyenUIHost \
  -destination "generic/platform=iOS" \
  -sdk iphoneos \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  -allowProvisioningUpdates \
  -skipPackagePluginValidation \
  -authenticationKeyID "$XCODE_AUTHENTICATION_KEY_ID" \
  -authenticationKeyIssuerID "$XCODE_AUTHENTICATION_KEY_ISSUER_ID" \
  -authenticationKeyPath "$XCODE_AUTHENTICATION_KEY_PATH"

echo "📤 Exporting .ipa..."
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportOptionsPlist exportOptions.plist \
  -exportPath "$BUILD_PATH" \
  -allowProvisioningUpdates \
  -skipPackagePluginValidation \
  -authenticationKeyID "$XCODE_AUTHENTICATION_KEY_ID" \
  -authenticationKeyIssuerID "$XCODE_AUTHENTICATION_KEY_ISSUER_ID" \
  -authenticationKeyPath "$XCODE_AUTHENTICATION_KEY_PATH"

echo "☁️ Uploading to App Store Connect..."
xcrun altool --upload-app \
  -f "$IPA_PATH" \
  -u "$APPLE_ID_USERNAME" \
  -p "$APPLE_APP_SPECIFIC_PASSWORD" \
  --type ios

echo "✅ Done!"
