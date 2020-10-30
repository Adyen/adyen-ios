# carthage.sh
# Usage example: ./carthage.sh build --platform iOS

# This script is copied from Carthage documentation
# https://github.com/Carthage/Carthage/blob/master/Documentation/Xcode12Workaround.md

set -euo pipefail

xcconfig=$(mktemp /tmp/static.xcconfig.XXXXXX)
trap 'rm -f "$xcconfig"' INT TERM HUP EXIT

# For Xcode 12 make sure EXCLUDED_ARCHS is set to arm architectures otherwise
# the build will fail on lipo due to duplicate architectures.

CURRENT_XCODE_VERSION=$(xcodebuild -version | grep "Build version" | cut -d' ' -f3)
echo "EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200__BUILD_$CURRENT_XCODE_VERSION = arm64 arm64e armv7 armv7s armv6 armv8" >> $xcconfig

echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200 = $(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200__BUILD_$(XCODE_PRODUCT_BUILD_VERSION))' >> $xcconfig
echo 'EXCLUDED_ARCHS = $(inherited) $(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_$(EFFECTIVE_PLATFORM_SUFFIX)__NATIVE_ARCH_64_BIT_$(NATIVE_ARCH_64_BIT)__XCODE_$(XCODE_VERSION_MAJOR))' >> $xcconfig

if [[ "$@" == *"--static"* ]]
then
  echo "▸ Is static framework..."
  echo "MACH_O_TYPE = staticlib" >>  $xcconfig
fi

export XCODE_XCCONFIG_FILE="$xcconfig"

IS_STATIC_ARGUMENT="--static"
ALL_ARGUMENTS="$@"
ARGUMENTS=$(echo $ALL_ARGUMENTS  | sed -e "s/$IS_STATIC_ARGUMENT//")
/usr/local/bin/carthage $ARGUMENTS
