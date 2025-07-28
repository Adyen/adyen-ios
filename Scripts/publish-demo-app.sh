#!/bin/bash

BUILD_PATH=Build-Temp

# Clean build
xcodebuild clean -project Adyen.xcodeproj \
  -scheme AdyenUIHost \
  -destination="generic/platform=iOS" \
  -sdk iphoneos \
  -configuration Release \
  -skipPackagePluginValidation

mkdir -p $BUILD_PATH

# Archive with explicit signing parameters
xcodebuild archive -project Adyen.xcodeproj \
  -scheme AdyenUIHost \
  -destination="generic/platform=iOS" \
  -sdk iphoneos \
  -configuration Release \
  -archivePath $BUILD_PATH/AdyenUIHost.xcarchive \
  -allowProvisioningUpdates \
  -skipPackagePluginValidation \
  -authenticationKeyID $XCODE_AUTHENTICATION_KEY_ID \
  -authenticationKeyIssuerID $XCODE_AUTHENTICATION_KEY_ISSUER_ID \
  -authenticationKeyPath $3 \
  CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" \
  DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM" \
  PROVISIONING_PROFILE_SPECIFIER="$PROVISIONING_PROFILE_SPECIFIER"

# Export archive for App Store distribution
xcodebuild -exportArchive \
  -archivePath $BUILD_PATH/AdyenUIHost.xcarchive \
  -exportOptionsPlist exportOptions.plist \
  -exportPath $BUILD_PATH \
  -allowProvisioningUpdates \
  -skipPackagePluginValidation \
  -authenticationKeyID $XCODE_AUTHENTICATION_KEY_ID \
  -authenticationKeyIssuerID $XCODE_AUTHENTICATION_KEY_ISSUER_ID \
  -authenticationKeyPath $3

# Upload to App Store Connect
xcrun altool --upload-app -f $BUILD_PATH/AdyenUIHost.ipa -u $1 -p $2 --type iphoneos
