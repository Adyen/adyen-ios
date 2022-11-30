#!/bin/bash

BUILD_PATH=Build-Temp

xcodebuild clean -project Adyen.xcodeproj \
 -scheme AdyenUIHost \
 -destination="generic/platform=iOS" \
 -sdk iphoneos \
 -configuration Release

mkdir -p $BUILD_PATH

xcodebuild archive -project Adyen.xcodeproj \
-scheme AdyenUIHost \
-destination="generic/platform=iOS" \
-sdk iphoneos \
-configuration Release \
-archivePath $BUILD_PATH/AdyenUIHost.xcarchive \
-allowProvisioningUpdates \

xcodebuild -exportArchive \
-archivePath $BUILD_PATH/AdyenUIHost.xcarchive \
-exportOptionsPlist exportOptions.plist \
-exportPath $BUILD_PATH \
-allowProvisioningUpdates \
-authenticationKeyID $XCODE_AUTHENTICATION_KEY_ID \
-authenticationKeyIssuerID $XCODE_AUTHENTICATION_KEY_ISSUER_ID

xcrun altool --upload-app -f $BUILD_PATH/AdyenUIHost.ipa -u $1 -p $2 --type iphoneos
