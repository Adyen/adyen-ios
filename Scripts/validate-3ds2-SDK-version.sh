#!/bin/sh

cardDetails3DS2SDKVersion=$(sed -rn 's/^.*public.*let.*threeDS2SdkVersion.*:.*String.*=.*"([0-9]+.[0-9].[0-9]+)".*$/\1/p' AdyenCard/Components/Card/ThreeDS2SdkVersion.swift)
cocoapods3DS2SDKVersion=$(sed -rn "s/^.*dependency.*\'Adyen3DS2'.*,.*'([0-9]+.[0-9].[0-9]+)'.*$/\1/p" Adyen.podspec)
carthage3DS2SDKVersion=$(sed -rn 's/^.*github.*"adyen\/adyen-3ds2-ios".*==.*([0-9]+.[0-9].[0-9]+).*$/\1/p' Cartfile)
swiftPackageManager3DS2SDKVersion=$(pcregrep -M --om-separator='.' --only-matching=1 --only-matching=2 --only-matching=3 '^[\n\s]*name:[\n\s]*"Adyen3DS2"[\n\s]*,[\n\s]*url[\n\s]*:[\n\s]*"https:\/\/github.com\/Adyen\/adyen\-3ds2\-ios"[\n\s]*,[\n\s]*\.exact\(Version\(([0-9]+)[\n\s]*,[\n\s]*([0-9]+)[\n\s]*,[\n\s]+([0-9]+)\)\)[\n\s]*$' Package.swift)

echo '\n'
echo '-----------------------------------------------------'
echo "ThreeDS2SdkVersion.swift: $cardDetails3DS2SDKVersion"
echo "Adyen.podspec:            $cocoapods3DS2SDKVersion"
echo "Cartfile:                 $carthage3DS2SDKVersion"
echo "Package.swift:            $swiftPackageManager3DS2SDKVersion"
echo '------------------------------------------------------\n'

declare -a array=( $cardDetails3DS2SDKVersion $cocoapods3DS2SDKVersion $carthage3DS2SDKVersion $swiftPackageManager3DS2SDKVersion )

declare -a uniq=($(echo "${array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

if [ ${#uniq[@]} -ne 1 ]; then
  RED='\033[0;31m'
  NC='\033[0m'
  echo "[ERROR] : ${RED}3DS2 SDK version in Package.swift, Cartfile, Adyen.podspec, and ThreeDS2SdkVersion.swift files donot match, please fix the conflict and try to commit again.${NC}"
  exit 1
fi
