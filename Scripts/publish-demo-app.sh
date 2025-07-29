#!/bin/bash
set -euo pipefail

BUILD_PATH=Build-Temp

# 1. Clean
xcodebuild clean -project Adyen.xcodeproj \
 -scheme AdyenUIHost \
 -destination="generic/platform=iOS" \
 -sdk iphoneos \
 -configuration Release \
 -skipPackagePluginValidation

mkdir -p $BUILD_PATH

# 2. Archive
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
 -authenticationKeyPath $3

# 3. Verify cert is installed
echo "🧾 Available signing identities:"
security find-identity -v -p codesigning

# 4. Export
xcodebuild -exportArchive \
 -archivePath $BUILD_PATH/AdyenUIHost.xcarchive \
 -exportOptionsPlist exportOptions.plist \
 -exportPath $BUILD_PATH \
 -allowProvisioningUpdates \
 -skipPackagePluginValidation \
 -authenticationKeyID $XCODE_AUTHENTICATION_KEY_ID \
 -authenticationKeyIssuerID $XCODE_AUTHENTICATION_KEY_ISSUER_ID \
 -authenticationKeyPath $3

# 5. Upload
xcrun altool --upload-app -f $BUILD_PATH/AdyenUIHost.ipa -u $1 -p $2 --type ios
