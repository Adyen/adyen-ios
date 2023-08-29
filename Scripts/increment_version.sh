#!/bin/bash

PODSPEC_PATH=Adyen.podspec
ADYEN_SDK_VERSION_PATH='./Adyen/Helpers/AdyenSdkVersion.swift'
CURRENT_VERSION=`agvtool mvers -terse1`
CURRENT_BUILD=`agvtool vers -terse`

echo ""
echo "Current Version: ${CURRENT_VERSION} (${CURRENT_BUILD})"
echo ""

NEW_VERSION=$1

if [ -n "$NEW_VERSION" ]
then
  agvtool new-marketing-version $NEW_VERSION
  agvtool next-version # Bumping build number

  sed -i '' -e "s/$CURRENT_VERSION/$NEW_VERSION/" $PODSPEC_PATH
  sed -i '' '$d' $ADYEN_SDK_VERSION_PATH && echo 'public let adyenSdkVersion: String = "'$NEW_VERSION'"' >> $ADYEN_SDK_VERSION_PATH
fi

CURRENT_VERSION=`agvtool mvers -terse1`
CURRENT_BUILD=`agvtool vers -terse`

echo "New Version:     ${CURRENT_VERSION} (${CURRENT_BUILD})"
echo ""
