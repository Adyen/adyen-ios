#!/bin/bash

BUILD_PATH=Build-Temp

xcodebuild -project Adyen.xcodeproj \
 -scheme AdyenUIHost \
 -destination="generic/platform=iOS" \
 -sdk iphoneos \
 -configuration Release clean

mkdir -p $BUILD_PATH

xcodebuild -project Adyen.xcodeproj \
-scheme AdyenUIHost \
-destination="generic/platform=iOS" \
-sdk iphoneos \
-configuration Release \
archive \
-archivePath $BUILD_PATH/AdyenUIHost.xcarchive

xcodebuild -exportArchive \
-archivePath $BUILD_PATH/AdyenUIHost.xcarchive \
-exportOptionsPlist exportOptions.plist \
-exportPath $BUILD_PATH \
-allowProvisioningUpdates

xcrun altool --upload-app -f $BUILD_PATH/AdyenUIHost.ipa -u $1 -p $2 --type iphoneos
