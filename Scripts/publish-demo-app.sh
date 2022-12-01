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
-authenticationKeyID $3 \
-authenticationKeyIssuerID $4 \
-authenticationKeyPath $5

xcodebuild -exportArchive \
-archivePath $BUILD_PATH/AdyenUIHost.xcarchive \
-exportOptionsPlist exportOptions.plist \
-exportPath $BUILD_PATH \
-allowProvisioningUpdates \
-authenticationKeyID $3 \
-authenticationKeyIssuerID $4 \
-authenticationKeyPath $5

xcrun altool --upload-app -f $BUILD_PATH/AdyenUIHost.ipa -u $1 -p $2 --type iphoneos
