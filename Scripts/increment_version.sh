#!/bin/bash

PODSPEC_PATH=Adyen.podspec
ADYEN_SDK_VERSION_PATH='./Adyen/Helpers/AdyenSdkVersion.swift'
CURRENT_VERSION=`agvtool vers -terse`

echo "Current Version: ${CURRENT_VERSION}"
NEW_VERSION=$1

if [ -n "$NEW_VERSION" ]
then
  agvtool new-version $NEW_VERSION
  agvtool new-marketing-version $NEW_VERSION

  sed -i '' -e "s/$CURRENT_VERSION/$NEW_VERSION/" $PODSPEC_PATH
  sed -i '' '$d' $ADYEN_SDK_VERSION_PATH && echo 'public let adyenSdkVersion: String = "'$NEW_VERSION'"' >> $ADYEN_SDK_VERSION_PATH
fi
