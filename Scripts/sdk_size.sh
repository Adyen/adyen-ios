#!/bin/zsh
set -eo pipefail

echo "--- Starting Local SDK Size Analysis Script (Final Version) ---"

# --- Configuration ---
PROJECT_NAME="Adyen.xcodeproj"
BUILD_OUTPUT_DIR="./build_output_local"
PROJECT_DERIVED_DATA_PATH="./DerivedData"
TOP_LEVEL_BUILD_SCHEME="AdyenUIHost"
FRAMEWORKS_PRODUCT_PATH="${BUILD_OUTPUT_DIR}/Release-iphoneos"

# --- Pre-build Cleanup & Directory Setup ---
echo "1. Performing cleanup and setting up directories..."
echo "   Removing existing DerivedData: ${PROJECT_DERIVED_DATA_PATH}"
rm -rf "${PROJECT_DERIVED_DATA_PATH}"

echo "   Removing existing script build output directory: ${BUILD_OUTPUT_DIR}"
rm -rf "${BUILD_OUTPUT_DIR}"

echo "   Creating fresh output directory for SYMROOT: ${BUILD_OUTPUT_DIR}"
mkdir -p "${BUILD_OUTPUT_DIR}"

# --- Build ---
echo "2. Building top-level scheme: ${TOP_LEVEL_BUILD_SCHEME}..."

set +e
xcodebuild_command="xcodebuild clean build \
    -project \"${PROJECT_NAME}\" \
    -scheme \"${TOP_LEVEL_BUILD_SCHEME}\" \
    -sdk iphoneos \
    -configuration Release \
    SYMROOT=\"${BUILD_OUTPUT_DIR}\" \
    -skipPackagePluginValidation"

echo "Executing build command:"
set -x
eval "${xcodebuild_command}" 2>&1 | tee "${BUILD_OUTPUT_DIR}/full_build_log_${TOP_LEVEL_BUILD_SCHEME}.txt"
BUILD_STATUS=${PIPESTATUS[0]}
set +x
set -e

if [[ ${BUILD_STATUS} -ne 0 ]]; then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!! Build for scheme '${TOP_LEVEL_BUILD_SCHEME}' FAILED!   !!"
    echo "!! The exact command executed was:                        !!"
    echo "!! ${xcodebuild_command}                                  !!"
    echo "!! Log: ${BUILD_OUTPUT_DIR}/full_build_log_${TOP_LEVEL_BUILD_SCHEME}.txt !!"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit 1
fi
echo "Top-level scheme '${TOP_LEVEL_BUILD_SCHEME}' built successfully."

# --- Measure SDK and Frameworks ---
echo "3. Measuring SDK and Frameworks..."

find "$FRAMEWORKS_PRODUCT_PATH" -name "*.framework" -type d | while read -r framework; do
  size=$(du -sh "$framework" | cut -f1)
  echo "$(basename "$framework"): $size"
done
