#!/bin/zsh
set -eo pipefail

echo "--- Starting Local SDK Size Analysis Script (Final Version) ---"

# --- Configuration ---
PROJECT_NAME="Adyen.xcodeproj"
TOP_LEVEL_BUILD_SCHEME="AdyenUIHost"
BUILD_CONFIGURATION="Release"

# --- Resolve DerivedData Product Path ---
echo "1. Resolving DerivedData path..."
DERIVED_DATA_PATH=$(xcodebuild -project "${PROJECT_NAME}" -scheme "${TOP_LEVEL_BUILD_SCHEME}" -showBuildSettings | grep -m1 -oE '(/.*DerivedData[^ ]*)')
FRAMEWORKS_PRODUCT_PATH="${DERIVED_DATA_PATH}/${BUILD_CONFIGURATION}-iphoneos"


echo "DerivedData path: ${DERIVED_DATA_PATH}"
echo "Framework product path: ${FRAMEWORKS_PRODUCT_PATH}"

# --- Clean DerivedData (optional but recommended) ---
echo "2. Cleaning DerivedData..."
rm -rf "${DERIVED_DATA_PATH}"

# --- Build ---
echo "3. Building top-level scheme: ${TOP_LEVEL_BUILD_SCHEME}..."

set +e

xcodebuild clean build \
  -project "${PROJECT_NAME}" \
  -scheme "${TOP_LEVEL_BUILD_SCHEME}" \
  -sdk iphoneos \
  -configuration "${BUILD_CONFIGURATION}" \
  -skipPackagePluginValidation \
  2>&1 | tee "${BUILD_OUTPUT_DIR}/full_build_log_${TOP_LEVEL_BUILD_SCHEME}.txt"

BUILD_STATUS=${PIPESTATUS[0]}

set +x
set -e

if [[ ${BUILD_STATUS} -ne 0 ]]; then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!! Build for scheme '${TOP_LEVEL_BUILD_SCHEME}' FAILED!   !!"
    echo "!! Log: ./build_log_${TOP_LEVEL_BUILD_SCHEME}.txt         !!"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit 1
fi
echo "Top-level scheme '${TOP_LEVEL_BUILD_SCHEME}' built successfully."

echo
echo "📦 Framework Sizes (sorted by size):"
echo "-------------------------------------"

# Collect all unique frameworks by path (most recent wins in case of duplicates)
typeset -A framework_map

while IFS= read -r fw; do
  name=$(basename "$fw")
  size_kb=$(du -sk "$fw" | cut -f1)
  framework_map["$name"]=$size_kb
done < <(find "$FRAMEWORKS_PRODUCT_PATH" -name "*.framework" -type d)

# Now sort and print them
for entry in ${(k)framework_map}; do
  size_kb=${framework_map[$entry]}
  if (( size_kb >= 1024 )); then
    size_fmt=$(echo "scale=1; $size_kb / 1024" | bc)MB
  else
    size_fmt=${size_kb}KB
  fi
  printf "%-30s %8s\n" "$entry" "$size_fmt"
done | sort -k2 -h
