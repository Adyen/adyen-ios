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

# Validate
if [[ -z "$APPLE_ID_USERNAME" || -z "$APPLE_APP_SPECIFIC_PASSWORD" || -z "$AUTH_KEY_PATH" ]]; then
  echo "❌ Usage: $0 <APPLE_ID_USERNAME> <APPLE_APP_SPECIFIC_PASSWORD> <AUTH_KEY_PATH>"
  exit 1
fi

# Required env vars
: "${XCODE_AUTHENTICATION_KEY_ID:?Environment variable XCODE_AUTHENTICATION_KEY_ID not set}"
: "${XCODE_AUTHENTICATION_KEY_ISSUER_ID:?Environment variable XCODE_AUTHENTICATION_KEY_ISSUER_ID not set}"
: "${CLIENT_KEY:?Environment variable CLIENT_KEY not set}"
: "${DEMO_SERVER_API_KEY:?Environment variable DEMO_SERVER_API_KEY not set}"
: "${MERCHANT_ACCOUNT:?Environment variable MERCHANT_ACCOUNT not set}"
: "${APPLE_DEVELOPMENT_TEAM_ID:?Environment variable APPLE_DEVELOPMENT_TEAM_ID not set}"
: "${ENVIRONMENT:?Environment variable ENVIRONMENT not set}"

# Debug print to verify environment variables, to be removed before merge
echo "Verifying required environment variables:"
echo "ADYEN_CLIENT_KEY: ${CLIENT_KEY:0:4}****"
echo "ADYEN_DEMO_SERVER_API_KEY: ${DEMO_SERVER_API_KEY:0:4}****"
echo "ADYEN_MERCHANT_ACCOUNT: ${MERCHANT_ACCOUNT:0:4}****"
echo "APPLE_TEAM_IDENTIFIER: ${APPLE_DEVELOPMENT_TEAM_ID}"

echo "🧹 Cleaning project..."
xcodebuild clean -project Adyen.xcodeproj \
  -scheme AdyenUIHost \
  -sdk iphoneos \
  -configuration Release \
  -skipPackagePluginValidation

echo "📁 Creating build directory..."
rm -rf "$BUILD_PATH"
mkdir -p "$BUILD_PATH"

# Add enhanced debugging without invasive changes
echo "BUILD DIAGNOSTICS: Secret Environment Variables Inspection"
echo "-------------------------------------------------------"
echo "Checking current environment variables:"
echo "CLIENT_KEY: ${CLIENT_KEY:0:4}****"
echo "DEMO_SERVER_API_KEY: ${DEMO_SERVER_API_KEY:0:4}****"
echo "MERCHANT_ACCOUNT: ${MERCHANT_ACCOUNT:0:4}****"
echo "APPLE_DEVELOPMENT_TEAM_ID: $APPLE_DEVELOPMENT_TEAM_ID"
echo "APPLE_PAY_MERCHANT_IDENTIFIER: ${APPLE_PAY_MERCHANT_IDENTIFIER:-"Not Set"}"
echo "-------------------------------------------------------"

echo "📦 Archiving app (signing disabled)..."
xcodebuild archive -project Adyen.xcodeproj \
  -scheme AdyenUIHost \
  -destination "generic/platform=iOS" \
  -sdk iphoneos \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  -skipPackagePluginValidation \
  -verbose \
  CODE_SIGNING_ALLOWED=NO \
  ADYEN_CLIENT_KEY="$CLIENT_KEY" \
  ADYEN_DEMO_SERVER_API_KEY="$DEMO_SERVER_API_KEY" \
  ADYEN_MERCHANT_ACCOUNT="$MERCHANT_ACCOUNT" \
  APPLE_TEAM_IDENTIFIER="$APPLE_DEVELOPMENT_TEAM_ID" \
  APPLE_PAY_MERCHANT_IDENTIFIER="${APPLE_PAY_MERCHANT_IDENTIFIER:-"merchant.com.adyen.test"}" | tee build_log.txt

# Enhanced debugging for Info.plist inspection
echo "📋 Listing all Info.plist files in the archive:"
find "$ARCHIVE_PATH" -name "Info.plist" -exec echo "Found: {}" \;

echo "🔍 Examining processed Info.plist files in the archive..."
find "$ARCHIVE_PATH" -name "Info.plist" -exec sh -c 'echo "\nInfo.plist at: $1"; plutil -p "$1" | grep -E "ADYEN_|APPLE_" || echo "No relevant keys found in $1"' sh {} \;

# Check if the environment variables are correctly set in the exportOptions.plist
echo "Checking export options plist..."
cat "$EXPORT_OPTIONS_PLIST"

# Detailed examination of the main app's Info.plist
MAIN_APP_INFO_PLIST="$ARCHIVE_PATH/Products/Applications/AdyenUIHost.app/Info.plist"
if [ -f "$MAIN_APP_INFO_PLIST" ]; then
  echo "\n⭐ DETAILED EXAMINATION of main app Info.plist:"
  echo "File exists at: $MAIN_APP_INFO_PLIST"
  
  # Check if variables were substituted correctly
  echo "\n📊 Checking variable substitution in main app Info.plist:"
  CLIENT_KEY_VALUE=$(plutil -extract ADYEN_CLIENT_KEY raw "$MAIN_APP_INFO_PLIST" 2>/dev/null)
  API_KEY_VALUE=$(plutil -extract ADYEN_DEMO_SERVER_API_KEY raw "$MAIN_APP_INFO_PLIST" 2>/dev/null)
  MERCHANT_VALUE=$(plutil -extract ADYEN_MERCHANT_ACCOUNT raw "$MAIN_APP_INFO_PLIST" 2>/dev/null)
  TEAM_ID_VALUE=$(plutil -extract APPLE_TEAM_IDENTIFIER raw "$MAIN_APP_INFO_PLIST" 2>/dev/null)
  
  # Show extracted values with appropriate masking for security
  echo "ADYEN_CLIENT_KEY: ${CLIENT_KEY_VALUE:+${CLIENT_KEY_VALUE:0:4}****}"
  echo "ADYEN_DEMO_SERVER_API_KEY: ${API_KEY_VALUE:+${API_KEY_VALUE:0:4}****}"
  echo "ADYEN_MERCHANT_ACCOUNT: ${MERCHANT_VALUE:+${MERCHANT_VALUE:0:4}****}"
  echo "APPLE_TEAM_IDENTIFIER: $TEAM_ID_VALUE"
  
  # Perform verification check
  if [[ -n "$CLIENT_KEY_VALUE" && -n "$API_KEY_VALUE" && -n "$MERCHANT_VALUE" ]]; then
    echo "✅ SUCCESS: All required values are properly substituted in the Info.plist!"
  else
    echo "⚠️ WARNING: Some values were not properly substituted in the Info.plist!"
    echo "The app may not work properly in TestFlight. Please check the environment variables."
    
    # Check for unresolved variables that might indicate substitution failures
    echo "Checking for unresolved variable patterns:"
    plutil -p "$MAIN_APP_INFO_PLIST" | grep -E "\$\(" || echo "No unresolved variables found."
  fi
  
  # Show summarized content of the main Info.plist
  echo "\n📜 Summary of main app Info.plist keys:"
  plutil -p "$MAIN_APP_INFO_PLIST" | grep -v "LSApplicationQueries\|CFBundleURLTypes" | head -30
  echo "... (output truncated for brevity)"
else
  echo "\n❌ ERROR: Main app Info.plist not found at expected location: $MAIN_APP_INFO_PLIST"
  echo "Searching for AdyenUIHost.app directory..."
  find "$ARCHIVE_PATH" -name "AdyenUIHost.app" -type d
fi

# Check the source Info.plist file to confirm it has the expected variables
echo "\n🔎 Verifying source Info.plist files:"
echo "Demo/UIKit/Info.plist contents (partial):"
if [ -f "$SCRIPT_DIR/../Demo/UIKit/Info.plist" ]; then
  grep -A 1 "ADYEN_\|APPLE_" "$SCRIPT_DIR/../Demo/UIKit/Info.plist" || echo "No ADYEN_ or APPLE_ keys found in source Info.plist"
else
  echo "Source Info.plist not found at $SCRIPT_DIR/../Demo/UIKit/Info.plist"
fi

# Inspect Info.plist files in the archive without modifying them
echo "Inspecting Info.plist files in the archive..."
find "$ARCHIVE_PATH" -name "Info.plist" -exec sh -c '
    echo "Info.plist at: $1"; 
    echo "Checking if any preprocessor variables remain unresolved:"
    plutil -p "$1" | grep -E "\$\(|ADYEN_|APPLE_" || echo "No relevant keys found in $1";
' sh {} \;

echo "📤 Exporting .ipa with manual signing..."
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
  -exportPath "$BUILD_PATH" \
  -allowProvisioningUpdates \
  -skipPackagePluginValidation \
  -verbose \
  -authenticationKeyID "$XCODE_AUTHENTICATION_KEY_ID" \
  -authenticationKeyIssuerID "$XCODE_AUTHENTICATION_KEY_ISSUER_ID" \
  -authenticationKeyPath "$AUTH_KEY_PATH" \
  ADYEN_CLIENT_KEY="$CLIENT_KEY" \
  ADYEN_DEMO_SERVER_API_KEY="$DEMO_SERVER_API_KEY" \
  ADYEN_MERCHANT_ACCOUNT="$MERCHANT_ACCOUNT" \
  APPLE_TEAM_IDENTIFIER="$APPLE_DEVELOPMENT_TEAM_ID" \
  APPLE_PAY_MERCHANT_IDENTIFIER="${APPLE_PAY_MERCHANT_IDENTIFIER:-"merchant.com.adyen.test"}"

# Check the final IPA without modifying it
echo "Attempting to analyze the final IPA file..."
TEMP_EXTRACT_DIR=$(mktemp -d)
mkdir -p "$TEMP_EXTRACT_DIR/extract"

# Try to extract the IPA just for inspection
if unzip -q "$IPA_PATH" -d "$TEMP_EXTRACT_DIR/extract" 2>/dev/null; then
  # Look for Info.plist files in the IPA and check if variables were properly substituted
  echo "Examining Info.plist files in the final IPA:"
  find "$TEMP_EXTRACT_DIR/extract" -name "Info.plist" -exec sh -c 'echo "Final Info.plist at: $1"; plutil -p "$1" | grep -E "\$\(|ADYEN_|APPLE_" || echo "No relevant keys found in $1"' sh {} \;
else
  echo "Note: Could not extract IPA for inspection - this is expected if signing is disabled"
fi

# Clean up
rm -rf "$TEMP_EXTRACT_DIR"

echo "☁️ Uploading to App Store Connect..."
xcrun altool --upload-app \
  -f "$IPA_PATH" \
  -u "$APPLE_ID_USERNAME" \
  -p "$APPLE_APP_SPECIFIC_PASSWORD" \
  --type ios

echo "✅ Upload complete!"
