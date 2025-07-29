#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Arguments:
# $1: APPLE_ID_USERNAME
# $2: APPLE_APP_SPECIFIC_PASSWORD
# $3: XCODE_AUTHENTICATION_KEY_PATH (path to your App Store Connect API Key .p8 file)
# $4: APPLE_DEVELOPMENT_TEAM_ID (your 10-character Team ID)
# $5: PROVISIONING_PROFILE_NAME (the exact name of your provisioning profile)
# $6: CODE_SIGN_IDENTITY_NAME (the exact name of your code signing certificate, e.g., "Apple Distribution: Adyen B.V. (ABCDEFG123)")
# $7: XCODE_AUTHENTICATION_KEY_ID (Key ID for App Store Connect API Key)
# $8: XCODE_AUTHENTICATION_KEY_ISSUER_ID (Issuer ID for App Store Connect API Key)

BUILD_PATH="Build-Temp"

# Assign arguments to meaningful variables
APPLE_ID_USERNAME="$1"
APPLE_APP_SPECIFIC_PASSWORD="$2"
XCODE_AUTHENTICATION_KEY_PATH="$3"
APPLE_DEVELOPMENT_TEAM_ID="$4"
PROVISIONING_PROFILE_NAME="$5"
CODE_SIGN_IDENTITY_NAME="$6"
XCODE_AUTHENTICATION_KEY_ID="$7"
XCODE_AUTHENTICATION_KEY_ISSUER_ID="$8"

echo "--- Script Parameters ---"
echo "Team ID: $APPLE_DEVELOPMENT_TEAM_ID"
echo "Provisioning Profile Name: $PROVISIONING_PROFILE_NAME"
echo "Code Sign Identity Name: $CODE_SIGN_IDENTITY_NAME"
echo "Authentication Key ID: $XCODE_AUTHENTICATION_KEY_ID"
echo "Authentication Key Issuer ID: $XCODE_AUTHENTICATION_KEY_ISSUER_ID"
echo "Authentication Key Path: $XCODE_AUTHENTICATION_KEY_PATH"
echo "-------------------------"

# Clean build folder
echo "Running xcodebuild clean..."
xcodebuild clean -project Adyen.xcodeproj \
 -scheme AdyenUIHost \
 -destination="generic/platform=iOS" \
 -sdk iphoneos \
 -configuration Release \
 -skipPackagePluginValidation

# Create build directory
mkdir -p "$BUILD_PATH"

# Archive the app with explicit code signing
echo "Running xcodebuild archive..."
xcodebuild archive -project Adyen.xcodeproj \
-scheme AdyenUIHost \
-destination="generic/platform=iOS" \
-sdk iphoneos \
-configuration Release \
-archivePath "$BUILD_PATH/AdyenUIHost.xcarchive" \
-allowProvisioningUpdates \
-skipPackagePluginValidation \
-authenticationKeyID "$XCODE_AUTHENTICATION_KEY_ID" \
-authenticationKeyIssuerID "$XCODE_AUTHENTICATION_KEY_ISSUER_ID" \
-authenticationKeyPath "$XCODE_AUTHENTICATION_KEY_PATH" \
PROVISIONING_PROFILE_SPECIFIER="$PROVISIONING_PROFILE_NAME" \
CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY_NAME" \
DEVELOPMENT_TEAM="$APPLE_DEVELOPMENT_TEAM_ID" \
CODE_SIGN_STYLE="Manual"

# Export the archive to an IPA
echo "Running xcodebuild exportArchive..."

# --- DEBUGGING: Print exportOptions.plist content ---
echo "--- Contents of exportOptions.plist ---"
if [ -f "exportOptions.plist" ]; then
    cat exportOptions.plist
else
    echo "Error: exportOptions.plist not found in the current directory!"
    exit 1 # This is a critical file, exit if not found.
fi
echo "--- End exportOptions.plist content ---"
# --- END DEBUGGING ---

xcodebuild -exportArchive \
-archivePath "$BUILD_PATH/AdyenUIHost.xcarchive" \
-exportOptionsPlist exportOptions.plist \
-exportPath "$BUILD_PATH" \
-allowProvisioningUpdates \
-skipPackagePluginValidation \
-authenticationKeyID "$XCODE_AUTHENTICATION_KEY_ID" \
-authenticationKeyIssuerID "$XCODE_AUTHENTICATION_KEY_ISSUER_ID" \
-authenticationKeyPath "$XCODE_AUTHENTICATION_KEY_PATH"

# Upload the IPA to App Store Connect
echo "Running xcrun altool --upload-app..."
# Note: altool is deprecated as of Xcode 15.3. 
# Use xcrun notarytool for macOS app notarization, 
# and xcrun transporter for uploading iOS apps.
# For now, keeping altool as per your original script.
xcrun altool --upload-app -f "$BUILD_PATH/AdyenUIHost.ipa" -u "$APPLE_ID_USERNAME" -p "$APPLE_APP_SPECIFIC_PASSWORD" --type iphoneos

echo "Publishing process completed."