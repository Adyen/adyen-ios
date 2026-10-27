#!/bin/sh

RED='\033[0;31m'
NC='\033[0m'

cardDetails3DS2SDKVersion=$(sed -En 's/^.*public.*let.*threeDS2SdkVersion.*:.*String.*=.*"([0-9]+.[0-9]+.[0-9]+)".*$/\1/p' AdyenCard/Components/Card/ThreeDS2SdkVersion.swift)
carthage3DS2SDKVersion=$(sed -En 's/^.*github.*"adyen\/adyen-3ds2-ios".*==.*([0-9]+.[0-9]+.[0-9]+).*$/\1/p' Cartfile)
swiftPackageManager3DS2SDKVersion=$(cat Package.swift | tr -d '[[:blank:]]\n\r' | sed -En 's/.*url:"https:\/\/github\.com\/Adyen\/adyen-3ds2-ios",exact:"([0-9]+\.[0-9]+\.[0-9]+)".*/\1/p')

echo '\n3DS2 SDK Version Validation'
echo '-----------------------------------------------------'
echo "ThreeDS2SdkVersion.swift: $cardDetails3DS2SDKVersion"
echo "Cartfile:                 $carthage3DS2SDKVersion"
echo "Package.swift:            $swiftPackageManager3DS2SDKVersion"
echo '------------------------------------------------------\n'

if [ -z "$cardDetails3DS2SDKVersion" ] || [ -z "$carthage3DS2SDKVersion" ] || [ -z "$swiftPackageManager3DS2SDKVersion" ]; then
  echo "[ERROR] : ${RED}Could not read the 3DS2 SDK version from one of the files above, please fix the file or the version parsing in this script.${NC}"
  exit 1
fi

declare -a array=( $cardDetails3DS2SDKVersion $carthage3DS2SDKVersion $swiftPackageManager3DS2SDKVersion )

declare -a uniq=($(echo "${array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

if [ ${#uniq[@]} -ne 1 ]; then
  echo "[ERROR] : ${RED}3DS2 SDK version in Package.swift, Cartfile, and ThreeDS2SdkVersion.swift files do not match, please fix the conflict and try to commit again.${NC}"
  exit 1
fi
