#!/bin/sh

adyenSdkVersion=$(agvtool what-marketing-version -terse1)
adyenHelpersAdyenSDKVersion=$(sed -En 's/^.*public.*let.*adyenSdkVersion.*:.*String.*=.*"([0-9]+.[0-9]+.[0-9]+)".*$/\1/p' Adyen/Helpers/AdyenSdkVersion.swift)
cocoapodsAdyenSDKVersion=$(sed -En "s/^.*s.version.*=.*'([0-9]+.[0-9]+.[0-9]+)'.*$/\1/p" Adyen.podspec)

echo '\nAdyen SDK Version Validation'
echo '-----------------------------------------------------'
echo "CFBundleShortVersionString: $adyenSdkVersion"
echo "AdyenSdkVersion.swift:      $adyenHelpersAdyenSDKVersion"
echo "Adyen.podspec:              $cocoapodsAdyenSDKVersion"
echo '------------------------------------------------------\n'

declare -a array=( $adyenSdkVersion $adyenHelpersAdyenSDKVersion $cocoapodsAdyenSDKVersion )

declare -a uniq=($(echo "${array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

if [ ${#uniq[@]} -ne 1 ]; then
  RED='\033[0;31m'
  NC='\033[0m'
  echo "[ERROR] : ${RED}Adyen SDK version in Info.plist (CFBundleShortVersionString), Adyen.podspec, and AdyenSdkVersion.swift files do not match, please fix the conflict and try to commit again.${NC}"
  exit 1
fi
