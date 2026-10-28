#!/bin/sh

RED='\033[0;31m'
NC='\033[0m'

adyenSdkVersion=$(agvtool what-marketing-version -terse1)
adyenHelpersAdyenSDKVersion=$(sed -En 's/^.*public.*let.*adyenSdkVersion.*:.*String.*=.*"([0-9]+.[0-9]+.[0-9]+)".*$/\1/p' Adyen/Helpers/AdyenSdkVersion.swift)

echo '\nAdyen SDK Version Validation'
echo '-----------------------------------------------------'
echo "CFBundleShortVersionString: $adyenSdkVersion"
echo "AdyenSdkVersion.swift:      $adyenHelpersAdyenSDKVersion"
echo '------------------------------------------------------\n'

if [ -z "$adyenSdkVersion" ] || [ -z "$adyenHelpersAdyenSDKVersion" ]; then
  echo "[ERROR] : ${RED}Could not read the Adyen SDK version from one of the files above, please fix the file or the version parsing in this script.${NC}"
  exit 1
fi

declare -a array=( $adyenSdkVersion $adyenHelpersAdyenSDKVersion )

declare -a uniq=($(echo "${array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

if [ ${#uniq[@]} -ne 1 ]; then
  echo "[ERROR] : ${RED}Adyen SDK version in Info.plist (CFBundleShortVersionString) and AdyenSdkVersion.swift files do not match, please fix the conflict and try to commit again.${NC}"
  exit 1
fi
