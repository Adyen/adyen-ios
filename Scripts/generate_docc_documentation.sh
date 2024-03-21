#!/bin/bash

set -e

# Since Docc doesn't support generating a single set of documentation
# for multiple modules, we create a temporary Swift package project.
# Swift package manager turns the different modules into a single module, which
# can then be processed by Docc.

TEMP_PROJECT_FOLDER=TempProject
TEMP_PROJECT_PATH=$TEMP_PROJECT_FOLDER/Adyen
FRAMEWORK_NAME=Adyen
DOCS_ROOT=docs
FINAL_DOCC_ARCHIVE_PATH=$DOCS_ROOT/docc_archive

rm -rf $TEMP_PROJECT_FOLDER

rm -rf $DOCS_ROOT

mkdir -p $DOCS_ROOT

mkdir -p $TEMP_PROJECT_FOLDER $TEMP_PROJECT_PATH $FINAL_DOCC_ARCHIVE_PATH

cd $TEMP_PROJECT_PATH
 
# Create a new Swift Package.
swift package init

cd ../../

rsync -r Adyen $TEMP_PROJECT_PATH/Sources/$FRAMEWORK_NAME
rsync -r AdyenActions $TEMP_PROJECT_PATH/Sources/$FRAMEWORK_NAME
rsync -r AdyenComponents $TEMP_PROJECT_PATH/Sources/$FRAMEWORK_NAME
rsync -r AdyenEncryption $TEMP_PROJECT_PATH/Sources/$FRAMEWORK_NAME
rsync -r AdyenCard $TEMP_PROJECT_PATH/Sources/$FRAMEWORK_NAME
rsync -r AdyenDropIn $TEMP_PROJECT_PATH/Sources/$FRAMEWORK_NAME
rsync -r AdyenSession $TEMP_PROJECT_PATH/Sources/$FRAMEWORK_NAME
rsync -r AdyenWeChatPay $TEMP_PROJECT_PATH/Sources/$FRAMEWORK_NAME
rsync -r AdyenSwiftUI $TEMP_PROJECT_PATH/Sources/$FRAMEWORK_NAME
rsync -r AdyenCashAppPay $TEMP_PROJECT_PATH/Sources/$FRAMEWORK_NAME

# Copy the Adyen.docc folder to the temp package source folder
cp -a $FRAMEWORK_NAME.docc $TEMP_PROJECT_PATH/Sources/$FRAMEWORK_NAME/$FRAMEWORK_NAME.docc

# Rename AdyenActions/Utilities/BundleSPMExtension.swift to AdyenActions/Utilities/ActionsBundleSPMExtension.swift
mv $TEMP_PROJECT_PATH/Sources/$FRAMEWORK_NAME/AdyenActions/Utilities/BundleSPMExtension.swift \
$TEMP_PROJECT_PATH/Sources/$FRAMEWORK_NAME/AdyenActions/Utilities/ActionsBundleSPMExtension.swift

# Rename Adyen/Utilities/BundleSPMExtension.swift to Adyen/Utilities/CoreBundleSPMExtension.swift
mv $TEMP_PROJECT_PATH/Sources/$FRAMEWORK_NAME/Adyen/Utilities/BundleSPMExtension.swift \
$TEMP_PROJECT_PATH/Sources/$FRAMEWORK_NAME/Adyen/Utilities/CoreBundleSPMExtension.swift

# Go back to Temp project root
cd $TEMP_PROJECT_PATH

echo "// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: \"Adyen\",
    defaultLocalization: \"en-us\",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: \"Adyen\",
            targets: [\"Adyen\"]
        )
    ],
    dependencies: [
        .package(
            name: \"Adyen3DS2\",
            url: \"https://github.com/Adyen/adyen-3ds2-ios\",
            .exact(Version(2, 4, 1))
        ),
        .package(
            name: \"AdyenNetworking\",
            url: \"https://github.com/Adyen/adyen-networking-ios\",
            .exact(Version(2, 0, 0))
        ),
        .package(
            name: \"AdyenWeChatPayInternal\",
            url: \"https://github.com/Adyen/adyen-wechatpay-ios\",
            .exact(Version(2, 1, 0))
        ),
        .package(
            name: \"PayKit\",
            url: \"https://github.com/cashapp/cash-app-pay-ios-sdk\",
            .exact(Version(0, 5, 1))
        )
    ],
    targets: [
        .target(
            name: \"Adyen\",
            dependencies: [
                .product(name: \"AdyenNetworking\", package: \"AdyenNetworking\"),
                .product(name: \"Adyen3DS2\", package: \"Adyen3DS2\"),
                .product(name: \"AdyenWeChatPayInternal\", package: \"AdyenWeChatPayInternal\"),
                .product(name: \"PayKit\", package: \"PayKit\"),
                .product(name: \"PayKitUI\", package: \"PayKit\")
            ],
            exclude: [
                \"Adyen/Info.plist\",
                \"AdyenActions/Info.plist\",
                \"AdyenComponents/Info.plist\",
                \"AdyenDropIn/Info.plist\",
                \"AdyenEncryption/Info.plist\",
                \"AdyenSwiftUI/Info.plist\",
                \"AdyenWeChatPay/Info.plist\",
                \"AdyenCashAppPay/AdyenCashAppPay.docc\",
                \"AdyenCard/Info.plist\",
                \"AdyenCard/Utilities/Non SPM Bundle Extension\",
                \"AdyenActions/Utilities/Non SPM Bundle Extension\",
                \"Adyen/Utilities/Non SPM Bundle Extension\"
            ]
        ),
    ]
)
" > Package.swift

rm -rf Tests

swift package update

DERIVED_DATA_PATH=.build

PROJECT_NAME='Adyen'
DESTINATION='generic/platform=iOS'

# PIF SMP fix
swift package dump-pif > /dev/null || true
xcodebuild clean -scheme "$PROJECT_NAME" -destination "$DESTINATION" -skipPackagePluginValidation > /dev/null || true

# Generate the docc archive.
xcodebuild docbuild \
 -scheme $PROJECT_NAME \
 -destination $DESTINATION \
 -configuration Release \
 -derivedDataPath $DERIVED_DATA_PATH \
 -skipPackagePluginValidation

# Go back to original project root
cd ../../

# Delete old DocC archive
rm -rf $FINAL_DOCC_ARCHIVE_PATH/$FRAMEWORK_NAME.doccarchive

# Move the new DocC archive to the its final place
mv $TEMP_PROJECT_PATH/$DERIVED_DATA_PATH/Build/Products/Release-iphoneos/$FRAMEWORK_NAME.doccarchive $FINAL_DOCC_ARCHIVE_PATH/$FRAMEWORK_NAME.doccarchive

# Generate the DocC html pages
$(xcrun --find docc) process-archive \
transform-for-static-hosting $FINAL_DOCC_ARCHIVE_PATH/$FRAMEWORK_NAME.doccarchive \
--output-path $DOCS_ROOT/html \
--hosting-base-path /adyen-ios/$LATEST_VERSION

# Clean up.
rm -rf $TEMP_PROJECT_FOLDER

REDIRECT_FOLDER=$DOCS_ROOT/redirect

mkdir -p $REDIRECT_FOLDER

cd $REDIRECT_FOLDER

echo "<head>
  <meta http-equiv=\"Refresh\" content=\"0; url='/adyen-ios/$LATEST_VERSION/documentation/adyen'\" />
</head>" > index.html
