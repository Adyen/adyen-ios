#!/bin/zsh
set -eo pipefail # Using zsh, keep exit on error and pipefail

echo "--- Starting Local SDK Size Analysis Script (Final Version) ---"

# --- Configuration ---
PROJECT_NAME="Adyen.xcodeproj"
BUILD_OUTPUT_DIR="./build_output_local" # Our custom SYMROOT for final products

# The derivedDataPath will be used by the 'xcodebuild build' command.
# This is where intermediate build files for the project and its dependencies (including SPM) go.
PROJECT_DERIVED_DATA_PATH="./DerivedData"

# The top-level scheme that integrates/uses all Adyen frameworks.
# Confirmed to be the scheme that builds all desired SDK frameworks into SYMROOT.
TOP_LEVEL_BUILD_SCHEME="AdyenUIHost"

# Path where final frameworks will be found directly within the SYMROOT.
# Based on your confirmed output, all frameworks land directly here.
FRAMEWORKS_PRODUCT_PATH="${BUILD_OUTPUT_DIR}/Release-iphoneos"
# No separate XCFRAMEWORKS_PRODUCT_PATH is needed if they are also in the same folder.
# If some frameworks are .xcframework bundles, they will still be found by `find ... *.xcframework`
# when searching the FRAMEWORKS_PRODUCT_PATH.


# --- Pre-build Cleanup & Directory Setup ---
echo "1. Performing cleanup and setting up directories..."

# Clean up the entire DerivedData directory that xcodebuild will use for its builds
echo "   Removing existing DerivedData: ${PROJECT_DERIVED_DATA_PATH}"
rm -rf "${PROJECT_DERIVED_DATA_PATH}"

# Clean up the build output directory for this script's final products (the SYMROOT)
echo "   Removing existing script build output directory: ${BUILD_OUTPUT_DIR}"
rm -rf "${BUILD_OUTPUT_DIR}"

echo "   Creating fresh output directory for SYMROOT: ${BUILD_OUTPUT_DIR}"
mkdir -p "${BUILD_OUTPUT_DIR}"
# Note: PROJECT_DERIVED_DATA_PATH will be created by xcodebuild itself when it runs.


# --- Build the top-level integrating scheme (`AdyenUIHost`) ---
# This single 'xcodebuild clean build' command handles everything.
echo "2. Building top-level scheme: ${TOP_LEVEL_BUILD_SCHEME}..."

set +e # Temporarily disable exit on error

xcodebuild_command="xcodebuild clean build \
    -project \"${PROJECT_NAME}\" \
    -scheme \"${TOP_LEVEL_BUILD_SCHEME}\" \
    -sdk iphoneos \
    -configuration Release \
    SYMROOT=\"${BUILD_OUTPUT_DIR}\" \
    -skipPackagePluginValidation"

# Execute the build command (full output to console and file)
echo "Executing build command (full output will be displayed):"
set -x # Re-enable set -x to see the command execution
eval "${xcodebuild_command}" 2>&1 | tee "${BUILD_OUTPUT_DIR}/full_build_log_${TOP_LEVEL_BUILD_SCHEME}.txt"
BUILD_STATUS=${PIPESTATUS[0]} # Get the exit status of xcodebuild (the first command in the pipe)
set +x # Disable tracing after the command executes
set -e

if [[ ${BUILD_STATUS} -ne 0 ]]; then # Use [[ ]] for zsh conditional
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!! Build for scheme '${TOP_LEVEL_BUILD_SCHEME}' FAILED!   !!"
    echo "!! The exact command executed was:                        !!"
    echo "!! ${xcodebuild_command}                                  !!"
    echo "!! REVIEW THE FULL BUILD LOG ABOVE OR IN: ${BUILD_OUTPUT_DIR}/full_build_log_${TOP_LEVEL_BUILD_SCHEME}.txt !!"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit 1
fi
echo "Top-level scheme '${TOP_LEVEL_BUILD_SCHEME}' built successfully."


# --- Measure SDK and Frameworks ---
# All frameworks are now expected to be directly in SYMROOT/Release-iphoneos/
echo "3. Measuring SDK and Frameworks..." # Renumbered step

find "$BUILD_OUTPUT_DIR/Release-iphoneos" -name "*.framework" -type d | while read -r framework; do
  size=$(du -sh "$framework" | cut -f1)
  echo "$(basename "$framework"): $size"
done
