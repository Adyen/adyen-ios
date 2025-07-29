#!/bin/bash

BUILD_PATH=Build-Temp
APPLE_ID_USERNAME="$1"
APPLE_APP_SPECIFIC_PASSWORD="$2"
XCODE_AUTHENTICATION_KEY_PATH="$3"

xcodebuild clean -project Adyen.xcodeproj \
 -scheme AdyenUIHost \
 -destination="generic/platform=iOS" \
 -sdk iphoneos \
 -configuration Release \
 -skipPackagePluginValidation

mkdir -p $BUILD_PATH

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
-authenticationKeyPath $XCODE_AUTHENTICATION_KEY_PATH

xcodebuild -exportArchive \
-archivePath $BUILD_PATH/AdyenUIHost.xcarchive \
-exportOptionsPlist exportOptions.plist \
-exportPath $BUILD_PATH \
-allowProvisioningUpdates \
-skipPackagePluginValidation \
-authenticationKeyID $XCODE_AUTHENTICATION_KEY_ID \
-authenticationKeyIssuerID $XCODE_AUTHENTICATION_KEY_ISSUER_ID \
-authenticationKeyPath $XCODE_AUTHENTICATION_KEY_PATH

xcrun altool --upload-app -f $BUILD_PATH/AdyenUIHost.ipa -u $1 -p $2 --type iphoneos