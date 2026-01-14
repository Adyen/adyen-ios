#!/bin/sh

cardDetails3DS2SDKVersion=$(sed -En 's/^.*public.*let.*threeDS2SdkVersion.*:.*String.*=.*"([0-9]+.[0-9]+.[0-9]+)".*$/\1/p' AdyenCard/Components/Card/ThreeDS2SdkVersion.swift)
cocoapods3DS2SDKVersion=$(sed -En "s/^.*dependency.*\'Adyen3DS2'.*,.*'([0-9]+.[0-9]+.[0-9]+)'.*$/\1/p" Adyen.podspec)
carthage3DS2SDKVersion=$(sed -En 's/^.*github.*"adyen\/adyen-3ds2-ios".*==.*([0-9]+.[0-9]+.[0-9]+).*$/\1/p' Cartfile)
swiftPackageManager3DS2SDKVersion=$(cat Package.swift | tr -d '[[:blank:]]\n\r' | sed -rn 's/.*name:"Adyen3DS2",url:"https:\/\/github\.com\/Adyen\/adyen\-3ds2\-ios",\.exact\(Version\(([0-9]+),([0-9]+),([0-9]+)\)\).*/\1.\2.\3/p')

echo '\n3DS2 SDK Version Validation'
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
  echo "[ERROR] : ${RED}3DS2 SDK version in Package.swift, Cartfile, Adyen.podspec, and ThreeDS2SdkVersion.swift files do not match, please fix the conflict and try to commit again.${NC}"
  exit 1
fi
