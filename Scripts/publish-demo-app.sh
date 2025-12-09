#!/bin/bash
set -euo pipefail

# Constants
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_PATH="$SCRIPT_DIR/../Build-Temp"
ARCHIVE_PATH="$BUILD_PATH/AdyenUIHost.xcarchive"
IPA_PATH="$BUILD_PATH/AdyenUIHost.ipa"
EXPORT_OPTIONS_PLIST="$SCRIPT_DIR/exportOptions.plist"

# Input arguments
APPLE_ID_USERNAME="$1"
APPLE_APP_SPECIFIC_PASSWORD="$2"
AUTH_KEY_PATH="$3"
DISTRIBUTION_TYPE="${4:-testflight}"  # testflight (default) or firebase

# Validate inputs
if [[ -z "$APPLE_ID_USERNAME" || -z "$APPLE_APP_SPECIFIC_PASSWORD" || -z "$AUTH_KEY_PATH" ]]; then
  echo "❌ Usage: $0 <APPLE_ID_USERNAME> <APPLE_APP_SPECIFIC_PASSWORD> <AUTH_KEY_PATH> [distribution_type]"
  exit 1
fi

if [[ "$DISTRIBUTION_TYPE" != "testflight" && "$DISTRIBUTION_TYPE" != "firebase" ]]; then
  echo "❌ distribution_type must be 'testflight' or 'firebase'"
  exit 1
fi

# Required environment variables (precondition checks)
: "${APPLE_ID_USERNAME:?Environment variable APPLE_ID_USERNAME not set}"
: "${APPLE_APP_SPECIFIC_PASSWORD:?Environment variable APPLE_APP_SPECIFIC_PASSWORD not set}"
: "${APPLE_PAY_MERCHANT_IDENTIFIER:?Environment variable APPLE_PAY_MERCHANT_IDENTIFIER not set}"
: "${XCODE_AUTHENTICATION_KEY_ID:?Environment variable XCODE_AUTHENTICATION_KEY_ID not set}"
: "${XCODE_AUTHENTICATION_KEY_ISSUER_ID:?Environment variable XCODE_AUTHENTICATION_KEY_ISSUER_ID not set}"
: "${XCODE_AUTHENTICATION_KEY_BASE64:?Environment variable XCODE_AUTHENTICATION_KEY_BASE64 not set}"
: "${FIREBASE_SERVICE_ACCOUNT_JSON:?Environment variable FIREBASE_SERVICE_ACCOUNT_JSON not set}"
: "${FIREBASE_APP_ID:?Environment variable FIREBASE_APP_ID not set}"

: "${MERCHANT_CLIENT_KEY:?Environment variable MERCHANT_CLIENT_KEY not set}"
: "${MERCHANT_SERVER_HOST:?Environment variable MERCHANT_SERVER_HOST not set}"
: "${MERCHANT_ACCOUNT:?Environment variable MERCHANT_ACCOUNT not set}"
: "${ADYEN_SERVER_API_KEY:?Environment variable ADYEN_SERVER_API_KEY not set}"
: "${APPLE_TEAM_IDENTIFIER:?Environment variable APPLE_TEAM_IDENTIFIER not set}"
: "${ENVIRONMENT:?Environment variable ENVIRONMENT not set}"

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
  -skipPackagePluginValidation \
  CODE_SIGNING_ALLOWED=NO \
  MERCHANT_CLIENT_KEY="$MERCHANT_CLIENT_KEY" \
  MERCHANT_SERVER_HOST="$MERCHANT_SERVER_HOST" \
  MERCHANT_ACCOUNT="$MERCHANT_ACCOUNT" \
  ADYEN_SERVER_API_KEY="$ADYEN_SERVER_API_KEY" \
  APPLE_TEAM_IDENTIFIER="$APPLE_TEAM_IDENTIFIER" \
  APPLE_PAY_MERCHANT_IDENTIFIER="${APPLE_PAY_MERCHANT_IDENTIFIER:-"merchant.com.adyen.test"}"

echo "📤 Exporting .ipa with manual signing..."
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
  -exportPath "$BUILD_PATH" \
  -allowProvisioningUpdates \
  -skipPackagePluginValidation \
  -authenticationKeyID "$XCODE_AUTHENTICATION_KEY_ID" \
  -authenticationKeyIssuerID "$XCODE_AUTHENTICATION_KEY_ISSUER_ID" \
  -authenticationKeyPath "$AUTH_KEY_PATH" \
  MERCHANT_CLIENT_KEY="$MERCHANT_CLIENT_KEY" \
  MERCHANT_SERVER_HOST="$MERCHANT_SERVER_HOST" \
  MERCHANT_ACCOUNT="$MERCHANT_ACCOUNT" \
  ADYEN_SERVER_API_KEY="$ADYEN_SERVER_API_KEY" \
  APPLE_TEAM_IDENTIFIER="$APPLE_TEAM_IDENTIFIER" \
  APPLE_PAY_MERCHANT_IDENTIFIER="${APPLE_PAY_MERCHANT_IDENTIFIER:-"merchant.com.adyen.test"}"

# ---- Upload step ----
if [[ "$DISTRIBUTION_TYPE" == "testflight" ]]; then
  echo "☁️ Uploading to App Store Connect (TestFlight)..."
  xcrun altool --upload-app \
    -f "$IPA_PATH" \
    -u "$APPLE_ID_USERNAME" \
    -p "$APPLE_APP_SPECIFIC_PASSWORD" \
    --type ios
  echo "✅ TestFlight upload complete!"

elif [[ "$DISTRIBUTION_TYPE" == "firebase" ]]; then
  echo "☁️ Uploading to Firebase App Distribution..."
  
  if [[ -z "${FIREBASE_SERVICE_ACCOUNT_JSON:-}" || -z "${FIREBASE_APP_ID:-}" ]]; then
    echo "❌ FIREBASE_SERVICE_ACCOUNT_JSON and FIREBASE_APP_ID environment variables must be set for Firebase distribution"
    exit 1
  fi

  # Write service account JSON to a temp file
  FIREBASE_JSON_PATH="$(mktemp)"
  echo "$FIREBASE_SERVICE_ACCOUNT_JSON" > "$FIREBASE_JSON_PATH"

  # Upload using Firebase CLI
  firebase appdistribution:distribute "$IPA_PATH" \
    --app "$FIREBASE_APP_ID" \
    --groups "ios-team" \
    --release-notes "Build from branch ${GITHUB_REF:-manual}" \
    --service-account "$FIREBASE_JSON_PATH"

  echo "✅ Firebase upload complete!"
fi
