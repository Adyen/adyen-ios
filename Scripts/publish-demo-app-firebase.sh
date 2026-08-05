#!/bin/bash
set -euo pipefail

# Constants
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_PATH="$SCRIPT_DIR/../Build-Temp"
ARCHIVE_PATH="$BUILD_PATH/AdyenUIHost.xcarchive"
IPA_PATH="$BUILD_PATH/AdyenUIHost.ipa"
INFO_PLIST_PATH="$SCRIPT_DIR/../Demo/UIKit/Info.plist"
INFO_PLIST_BACKUP_PATH="$INFO_PLIST_PATH.original"
EXPORT_OPTIONS_PLIST="$SCRIPT_DIR/exportOptions-Firebase.plist"
EXPORT_CONFIGURATION="Firebase"
PLIST_BUDDY=/usr/libexec/PlistBuddy

# Secrets written to disk further down, wiped by the cleanup below.
AUTH_KEY_PATH=""
FIREBASE_JSON_PATH=""

# Set on the last line; anything earlier means the script was cut short.
SCRIPT_SUCCEEDED=false

# Single EXIT handler: a second `trap ... EXIT` would silently replace this one.
# The status has to be re-raised explicitly, and a premature exit forced to non-zero: with an EXIT
# trap installed, bash reports 0 for `${VAR:?}` and `set -u` aborts, which would turn a missing
# secret into a green build.
cleanup() {
  local exit_status=$?
  if [[ -f "$INFO_PLIST_BACKUP_PATH" ]]; then
    mv -f "$INFO_PLIST_BACKUP_PATH" "$INFO_PLIST_PATH"
  fi
  if [[ -n "$AUTH_KEY_PATH" ]]; then
    rm -f "$AUTH_KEY_PATH"
  fi
  if [[ -n "$FIREBASE_JSON_PATH" ]]; then
    rm -f "$FIREBASE_JSON_PATH"
  fi
  if [[ "$SCRIPT_SUCCEEDED" != true ]] && [[ "$exit_status" -eq 0 ]]; then
    exit_status=1
  fi
  exit "$exit_status"
}
trap cleanup EXIT

# ---- Version ----
# Firebase App Distribution labels every release with the CFBundleShortVersionString (CFBundleVersion)
# baked into the uploaded IPA, so both have to be set before archiving.
# BUILD_VERSION_NAME is required; an empty BUILD_NUMBER keeps the one committed in the project.
BUILD_NUMBER="${BUILD_NUMBER:-}"

# Optional free-text note shown above the build metadata in Firebase. Defaulted here because `set -u`
# would otherwise abort when the caller omits it.
RELEASE_NOTES="${RELEASE_NOTES:-}"

echo "📦 Using Firebase export options: $EXPORT_OPTIONS_PLIST"

# ---- Required environment variables ----
# Version
: "${BUILD_VERSION_NAME:?Environment variable BUILD_VERSION_NAME not set}"

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

# Firebase configuration
: "${FIREBASE_SERVICE_ACCOUNT_JSON:?Environment variable FIREBASE_SERVICE_ACCOUNT_JSON not set}"
: "${FIREBASE_APP_ID:?Environment variable FIREBASE_APP_ID not set}"
: "${FIREBASE_RELEASE_NAME:?Environment variable FIREBASE_RELEASE_NAME not set}"

echo "ℹ️ Firebase env vars validated."

# ---- Apply the version name ----
# The backup is restored by cleanup() so a local run doesn't leave the working tree dirty.
echo "🏷️ Setting version name to $BUILD_VERSION_NAME..."
cp "$INFO_PLIST_PATH" "$INFO_PLIST_BACKUP_PATH"
"$PLIST_BUDDY" -c "Set :CFBundleShortVersionString $BUILD_VERSION_NAME" "$INFO_PLIST_PATH"

# ---- Apply the build number override ----
# CFBundleVersion already resolves to $(CURRENT_PROJECT_VERSION), so an archive setting is enough.
ARCHIVE_OVERRIDES=()
if [[ -n "$BUILD_NUMBER" ]]; then
  echo "🏷️ Setting build number to $BUILD_NUMBER..."
  ARCHIVE_OVERRIDES+=("CURRENT_PROJECT_VERSION=$BUILD_NUMBER")
fi

RESOLVED_VERSION_NAME="$("$PLIST_BUDDY" -c "Print :CFBundleShortVersionString" "$INFO_PLIST_PATH")"
echo "🔖 Distributing $RESOLVED_VERSION_NAME (${BUILD_NUMBER:-project default})"

# ---- Install certificates & provisioning profiles ----
echo "🛡️ Installing certificates and provisioning profile..."

CERTIFICATE_PATH="$RUNNER_TEMP/build_certificate.p12"
DEV_CERTIFICATE_PATH="$RUNNER_TEMP/dev_certificate.p12"
PP_PATH="$RUNNER_TEMP/build_pp.mobileprovision"
KEYCHAIN_PATH="$RUNNER_TEMP/app-signing.keychain-db"
PROFILES_PATH="$HOME/Library/MobileDevice/Provisioning Profiles"

echo -n "$BUILD_CERTIFICATE_BASE64" | base64 --decode -o "$CERTIFICATE_PATH"
echo -n "$DEVELOPMENT_CERTIFICATE_BASE64" | base64 --decode -o "$DEV_CERTIFICATE_PATH"
echo -n "$BUILD_PROVISION_PROFILE_BASE64" | base64 --decode -o "$PP_PATH"

security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"

security import "$CERTIFICATE_PATH" -P "$P12_PASSWORD" -A -t cert -f pkcs12 -k "$KEYCHAIN_PATH"
security import "$DEV_CERTIFICATE_PATH" -P "$P12_PASSWORD" -A -t cert -f pkcs12 -k "$KEYCHAIN_PATH"
security list-keychain -d user -s "$KEYCHAIN_PATH"

mkdir -p "$PROFILES_PATH"
cp "$PP_PATH" "$PROFILES_PATH"

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
  APPLE_PAY_MERCHANT_IDENTIFIER="${APPLE_PAY_MERCHANT_IDENTIFIER:-"merchant.com.adyen.test"}" \
  ${ARCHIVE_OVERRIDES[@]+"${ARCHIVE_OVERRIDES[@]}"}

# ---- Export IPA with signing ----
AUTH_KEY_PATH="$RUNNER_TEMP/auth_key.p8"
echo -n "$XCODE_AUTHENTICATION_KEY_BASE64" | base64 --decode > "$AUTH_KEY_PATH"
chmod 600 "$AUTH_KEY_PATH"  # redirection uses the umask, so restrict explicitly. Removed by cleanup()

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

# ---- Distribution ----
echo "🔥 Uploading to Firebase App Distribution..."

# Write service account JSON to temp file.
# mktemp creates it 0600 regardless of umask, so no chmod is needed here — unlike AUTH_KEY_PATH above,
# which shell redirection creates using the umask. Removed by cleanup().
FIREBASE_JSON_PATH="$(mktemp)"
echo "$FIREBASE_SERVICE_ACCOUNT_JSON" > "$FIREBASE_JSON_PATH"
export GOOGLE_APPLICATION_CREDENTIALS="$FIREBASE_JSON_PATH"

# A caller-provided note is used verbatim, with no build metadata appended: recurring builds such as
# the nightly have to report byte-identical release notes on every run. Without one, fall back to the
# metadata so ad-hoc builds stay traceable back to a commit.
if [[ -n "$RELEASE_NOTES" ]]; then
  FIREBASE_RELEASE_NOTES="$RELEASE_NOTES"
else
  FIREBASE_RELEASE_NOTES="Release: ${FIREBASE_RELEASE_NAME}, Version: ${RESOLVED_VERSION_NAME} (${BUILD_NUMBER:-project default}), Branch: ${GITHUB_REF_NAME:-manual}, Build: ${GITHUB_SHA:-manual}"
fi

# Upload
firebase appdistribution:distribute "$IPA_PATH" \
  --app "$FIREBASE_APP_ID" \
  --groups "ios-checkout-team" \
  --release-notes "$FIREBASE_RELEASE_NOTES"

echo "✅ Firebase upload complete! Release name: $FIREBASE_RELEASE_NAME"

SCRIPT_SUCCEEDED=true
