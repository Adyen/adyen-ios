#!/bin/bash
set -euo pipefail

# Constants
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_PATH="$SCRIPT_DIR/../Build-Temp"
ARCHIVE_PATH="$BUILD_PATH/AdyenUIHost.xcarchive"
IPA_PATH="$BUILD_PATH/AdyenUIHost.ipa"
EXPORT_OPTIONS_PLIST="$SCRIPT_DIR/exportOptions.plist"
EXPORT_CONFIGURATION="Release"

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
  -configuration "$EXPORT_CONFIGURATION" \
  -skipPackagePluginValidation

# ---- Prepare build folder ----
echo "📁 Creating build directory..."
rm -rf "$BUILD_PATH"
mkdir -p "$BUILD_PATH"

# ---- Archive app ----
echo "📦 Archiving app (signing disabled)..."
xcodebuild archive \
  -project Adyen.xcodeproj \
  -scheme AdyenUIHost \
  -configuration "$EXPORT_CONFIGURATION" \
  -archivePath "$ARCHIVE_PATH" \
  -destination "generic/platform=iOS" \
  -sdk iphoneos \
  -skipPackagePluginValidation \
  CODE_SIGNING_ALLOWED=NO \
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
  -authenticationKeyID "$XCODE_AUTHENTICATION_KEY_ID" \
  -authenticationKeyIssuerID "$XCODE_AUTHENTICATION_KEY_ISSUER_ID" \
  -authenticationKeyPath "$AUTH_KEY_PATH" \
  -skipPackagePluginValidation

# ---- Upload to App Store Connect (TestFlight) ----
echo "☁️ Uploading to App Store Connect (TestFlight)..."
xcrun altool --upload-app \
  -f "$IPA_PATH" \
  -u "$APPLE_ID_USERNAME" \
  -p "$APPLE_APP_SPECIFIC_PASSWORD" \
  --type ios

echo "✅ TestFlight upload complete!"
