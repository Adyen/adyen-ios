#!/bin/bash
set -euo pipefail

# Constants
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_PATH="$SCRIPT_DIR/../Build-Temp"
ARCHIVE_PATH="$BUILD_PATH/AdyenUIHost.xcarchive"
IPA_PATH="$BUILD_PATH/AdyenUIHost.ipa"
EXPORT_OPTIONS_PLIST="$SCRIPT_DIR/exportOptions.plist"

# Input: Path to App Store Connect API Key (.p8)
AUTH_KEY_PATH_RAW="${1:-}"
if [[ -z "$AUTH_KEY_PATH_RAW" ]]; then
    echo "Usage: $0 <AUTH_KEY_PATH>"
    exit 1
fi

# Resolve absolute path to the auth key
AUTH_KEY_PATH="$(cd "$(dirname "$AUTH_KEY_PATH_RAW")" && pwd)/$(basename "$AUTH_KEY_PATH_RAW")"


# Validate that file exists
if [[ ! -f "$AUTH_KEY_PATH" ]]; then
    echo "❌ Error: AUTH_KEY_PATH does not point to a valid file: $AUTH_KEY_PATH"
    exit 1
fi

# Required env vars
: "${XCODE_AUTHENTICATION_KEY_ID:?Environment variable XCODE_AUTHENTICATION_KEY_ID not set}"
: "${XCODE_AUTHENTICATION_KEY_ISSUER_ID:?Environment variable XCODE_AUTHENTICATION_KEY_ISSUER_ID not set}"

# Validate
if [[ -z "$AUTH_KEY_PATH" ]]; then
    echo "Usage: $0 <AUTH_KEY_PATH>"
    exit 1
fi

echo "🧹 Cleaning project..."
xcodebuild clean -project Adyen.xcodeproj \
  -scheme AdyenUIHost \
  -sdk iphoneos \
  -configuration Release \
  -skipPackagePluginValidation

echo "📁 Creating build directory..."
rm -rf "$BUILD_PATH"
mkdir -p "$BUILD_PATH"

echo "📦 Archiving app (signing disabled)..."
xcodebuild archive -project Adyen.xcodeproj \
  -scheme AdyenUIHost \
  -destination "generic/platform=iOS" \
  -sdk iphoneos \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  -allowProvisioningUpdates \
  -skipPackagePluginValidation \
  CODE_SIGNING_ALLOWED=NO

echo "📤 Exporting .ipa with manual signing..."
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
  -exportPath "$BUILD_PATH" \
  -allowProvisioningUpdates \
  -skipPackagePluginValidation \
  -authenticationKeyID "$XCODE_AUTHENTICATION_KEY_ID" \
  -authenticationKeyIssuerID "$XCODE_AUTHENTICATION_KEY_ISSUER_ID" \
  -authenticationKeyPath "$AUTH_KEY_PATH"

echo "☁️ Uploading to App Store Connect..."
xcrun altool --upload-app \
  -f "$IPA_PATH" \
  -u "$APPLE_ID_USERNAME" \
  -p "$APPLE_APP_SPECIFIC_PASSWORD" \
  --type ios

echo "✅ Upload complete!"