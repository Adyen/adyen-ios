#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Arguments:
# $1: APPLE_ID_USERNAME
# $2: APPLE_APP_SPECIFIC_PASSWORD
# $3: XCODE_AUTHENTICATION_KEY_PATH (from workflow secrets)
# $4: APPLE_DEVELOPMENT_TEAM_ID (from workflow secrets)
# $5: PROVISIONING_PROFILE_NAME (e.g., "Adyen App Store Distribution Profile")
# $6: CODE_SIGN_IDENTITY_NAME (e.g., "Apple Distribution: Adyen B.V. (YOUR_TEAM_ID)")
# $7: XCODE_AUTHENTICATION_KEY_ID (from workflow secrets, directly passed for xcodebuild)
# $8: XCODE_AUTHENTICATION_KEY_ISSUER_ID (from workflow secrets, directly passed for xcodebuild)


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
# Explicitly set code signing identity and provisioning profile
PROVISIONING_PROFILE_SPECIFIER="$PROVISIONING_PROFILE_NAME" \
CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY_NAME" \
DEVELOPMENT_TEAM="$APPLE_DEVELOPMENT_TEAM_ID" \
CODE_SIGN_STYLE="Manual"

# Export the archive to an IPA
echo "Running xcodebuild exportArchive..."
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
xcrun altool --upload-app -f "$BUILD_PATH/AdyenUIHost.ipa" -u "$APPLE_ID_USERNAME" -p "$APPLE_APP_SPECIFIC_PASSWORD" --type iphoneos

echo "Publishing process completed."