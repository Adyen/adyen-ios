#!/bin/bash

set -euo pipefail

BUILD_PATH=Build-Temp
XC_CONFIG_PATH=ci/CI.xcconfig

echo "📁 Creating xcconfig file to disable signing..."
mkdir -p ci
cat > $XC_CONFIG_PATH <<EOF
CODE_SIGNING_ALLOWED = NO
CODE_SIGNING_REQUIRED = NO
CODE_SIGN_IDENTITY =
EOF

echo "🧹 Cleaning previous build..."
xcodebuild clean -project Adyen.xcodeproj \
  -scheme AdyenUIHost \
  -destination="generic/platform=iOS" \
  -sdk iphoneos \
  -configuration Release \
  -skipPackagePluginValidation \
  -xcconfig $XC_CONFIG_PATH

echo "📁 Creating build path..."
mkdir -p $BUILD_PATH

echo "📦 Archiving..."
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
  -xcconfig $XC_CONFIG_PATH

echo "📤 Exporting IPA..."
xcodebuild -exportArchive \
  -archivePath $BUILD_PATH/AdyenUIHost.xcarchive \
  -exportOptionsPlist exportOptions.plist \
  -exportPath $BUILD_PATH \
  -allowProvisioningUpdates \
  -skipPackagePluginValidation \
  -authenticationKeyID $XCODE_AUTHENTICATION_KEY_ID \
  -authenticationKeyIssuerID $XCODE_AUTHENTICATION_KEY_ISSUER_ID \
  -authenticationKeyPath $3

echo "🚀 Uploading to App Store Connect..."
xcrun altool --upload-app -f $BUILD_PATH/AdyenUIHost.ipa -u $1 -p $2 --type iphoneos
