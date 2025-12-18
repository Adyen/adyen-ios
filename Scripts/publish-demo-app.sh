#!/bin/bash
set -euo pipefail

# Constants
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_PATH="$SCRIPT_DIR/../Build-Temp"
ARCHIVE_PATH="$BUILD_PATH/AdyenUIHost.xcarchive"
IPA_PATH="$BUILD_PATH/AdyenUIHost.ipa"

# Input arguments
DISTRIBUTION_TYPE="${1:-testflight}"  # testflight (default) or firebase

# Validate input
if [[ -z "$DISTRIBUTION_TYPE" ]]; then
  echo "❌ Usage: $0 [distribution_type]"
  exit 1
fi

if [[ "$DISTRIBUTION_TYPE" != "testflight" && "$DISTRIBUTION_TYPE" != "firebase" ]]; then
  echo "❌ distribution_type must be 'testflight' or 'firebase'"
  exit 1
fi

# ---- Determine export options ----
if [[ "$DISTRIBUTION_TYPE" == "testflight" ]]; then
  echo "📦 Using TestFlight export options"
  EXPORT_OPTIONS_PLIST="$SCRIPT_DIR/exportOptions.plist"
  BUNDLE_ID_ARGS=()  # Use default bundle ID
else
  echo "📦 Using Firebase export options"
  EXPORT_OPTIONS_PLIST="$SCRIPT_DIR/exportOptions-Firebase.plist"
  BUNDLE_ID_ARGS=("PRODUCT_BUNDLE_IDENTIFIER=com.adyen.enterprise.checkout.demo.uikit")
fi

echo "📋 Using export options: $EXPORT_OPTIONS_PLIST"

# ---- Required environment variables ----
# Apple credentials
: "${APPLE_ID_USERNAME:?Environment variable APPLE_ID_USERNAME not set}"
: "${APPLE_APP_SPECIFIC_PASSWORD:?Environment variable APPLE_APP_SPECIFIC_PASSWORD not set}"

# Xcode signing key
: "${XCODE_AUTHENTICATION_KEY_ID:?Environment variable XCODE_AUTHENTICATION_KEY_ID not set}"
: "${XCODE_AUTHENTICATION_KEY_ISSUER_ID:?Environment variable XCODE_AUTHENTICATION_KEY_ISSUER_ID not set}"
: "${XCODE_AUTHENTICATION_KEY_BASE64:?Environment variable XCODE_AUTHENTICATION_KEY_BASE64 not set}"

# Build certificates & profiles
: "${BUILD_CERTIFICATE_BASE64:?Environment variable BUILD_CERTIFICATE_BASE64 not set}"
: "${DEVELOPMENT_CERTIFICATE_BASE64:?Environment variable DEVELOPMENT_CERTIFICATE_BASE64 not set}"
: "${P12_PASSWORD:?Environment variable P12_PASSWORD not set}"
: "${BUILD_PROVISION_PROFILE_BASE64:?Environment variable BUILD_PROVISION_PROFILE_BASE64 not set}"
: "${KEYCHAIN_PASSWORD:?Environment variable KEYCHAIN_PASSWORD not set}"

# App configuration
: "${MERCHANT_CLIENT_KEY:?Environment variable MERCHANT_CLIENT_KEY not set}"
: "${MERCHANT_SERVER_HOST:?Environment variable MERCHANT_SERVER_HOST not set}"
: "${MERCHANT_ACCOUNT:?Environment variable MERCHANT_ACCOUNT not set}"
: "${ADYEN_SERVER_API_KEY:?Environment variable ADYEN_SERVER_API_KEY not set}"
: "${APPLE_TEAM_IDENTIFIER:?Environment variable APPLE_TEAM_IDENTIFIER not set}"
: "${ENVIRONMENT:?Environment variable ENVIRONMENT not set}"

# Firebase only (if distributing to Firebase)
if [[ "$DISTRIBUTION_TYPE" == "firebase" ]]; then
  : "${FIREBASE_SERVICE_ACCOUNT_JSON:?Environment variable FIREBASE_SERVICE_ACCOUNT_JSON not set}"
  : "${FIREBASE_APP_ID:?Environment variable FIREBASE_APP_ID not set}"
  : "${FIREBASE_RELEASE_NAME:?Environment variable FIREBASE_RELEASE_NAME not set}"
  echo "ℹ️ Firebase distribution selected — Firebase env vars validated."
fi

# ---- Install certificates & provisioning profiles ----
echo "🛡️ Installing certificates and provisioning profile..."

CERTIFICATE_PATH=$RUNNER_TEMP/build_certificate.p12
DEV_CERTIFICATE_PATH=$RUNNER_TEMP/dev_certificate.p12
PP_PATH=$RUNNER_TEMP/build_pp.mobileprovision
KEYCHAIN_PATH=$RUNNER_TEMP/app-signing.keychain-db

echo -n "$BUILD_CERTIFICATE_BASE64" | base64 --decode -o $CERTIFICATE_PATH
echo -n "$DEVELOPMENT_CERTIFICATE_BASE64" | base64 --decode -o $DEV_CERTIFICATE_PATH
echo -n "$BUILD_PROVISION_PROFILE_BASE64" | base64 --decode -o $PP_PATH

security create-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
security set-keychain-settings -lut 21600 $KEYCHAIN_PATH
security unlock-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH

security import $CERTIFICATE_PATH -P "$P12_PASSWORD" -A -t cert -f pkcs12 -k $KEYCHAIN_PATH
security import $DEV_CERTIFICATE_PATH -P "$P12_PASSWORD" -A -t cert -f pkcs12 -k $KEYCHAIN_PATH
security list-keychain -d user -s $KEYCHAIN_PATH

mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp $PP_PATH ~/Library/MobileDevice/Provisioning\ Profiles

echo "✅ Certificates and provisioning profile installed."

# ---- Clean project ----
echo "🧹 Cleaning project..."
xcodebuild clean -project Adyen.xcodeproj \
  -scheme AdyenUIHost \
  -sdk iphoneos \
  -configuration "Release" \
  -skipPackagePluginValidation

# ---- Prepare build folder ----
echo "📁 Creating build directory..."
rm -rf "$BUILD_PATH"
mkdir -p "$BUILD_PATH"

# ---- Archive app ----
echo "📦 Archiving app (signing disabled)..."
xcodebuild archive -project Adyen.xcodeproj \
  -scheme AdyenUIHost \
  -destination "generic/platform=iOS" \
  -sdk iphoneos \
  -configuration "Release" \
  -archivePath "$ARCHIVE_PATH" \
  -skipPackagePluginValidation \
  CODE_SIGNING_ALLOWED=NO \
  "${BUNDLE_ID_ARGS[@]}" \
  MERCHANT_CLIENT_KEY="$MERCHANT_CLIENT_KEY" \
  MERCHANT_SERVER_HOST="$MERCHANT_SERVER_HOST" \
  MERCHANT_ACCOUNT="$MERCHANT_ACCOUNT" \
  ADYEN_SERVER_API_KEY="$ADYEN_SERVER_API_KEY" \
  APPLE_TEAM_IDENTIFIER="$APPLE_TEAM_IDENTIFIER" \
  APPLE_PAY_MERCHANT_IDENTIFIER="${APPLE_PAY_MERCHANT_IDENTIFIER:-"merchant.com.adyen.test"}"

# ---- Export IPA with signing ----
AUTH_KEY_PATH="$RUNNER_TEMP/auth_key.p8"
echo -n "$XCODE_AUTHENTICATION_KEY_BASE64" | base64 --decode > "$AUTH_KEY_PATH"
chmod 600 "$AUTH_KEY_PATH"  # restrict permissions

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

# ---- Distribution ----
if [[ "$DISTRIBUTION_TYPE" == "testflight" ]]; then
  echo "☁️ Uploading to App Store Connect (TestFlight)..."
  xcrun altool --upload-app \
    -f "$IPA_PATH" \
    -u "$APPLE_ID_USERNAME" \
    -p "$APPLE_APP_SPECIFIC_PASSWORD" \
    --type ios
  echo "✅ TestFlight upload complete!"

elif [[ "$DISTRIBUTION_TYPE" == "firebase" ]]; then
  echo "🔥 Uploading to Firebase App Distribution..."

  # Write service account JSON to temp file
  FIREBASE_JSON_PATH="$(mktemp)"
  echo "$FIREBASE_SERVICE_ACCOUNT_JSON" > "$FIREBASE_JSON_PATH"
  export GOOGLE_APPLICATION_CREDENTIALS=$FIREBASE_JSON_PATH

  # Upload
  firebase appdistribution:distribute "$IPA_PATH" \
    --app "$FIREBASE_APP_ID" \
    --groups "ios-checkout-team" \
    --release-notes "Branch: ${GITHUB_REF_NAME:-manual}, Build: ${GITHUB_SHA:-manual}"

  echo "✅ Firebase upload complete! Release name: $FIREBASE_RELEASE_NAME"
fi
