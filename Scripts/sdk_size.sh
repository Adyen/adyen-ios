#!/bin/zsh
set -eo pipefail

echo "--- Starting Local SDK Size Analysis Script (Default DerivedData) ---"

# --- Configuration ---
PROJECT_NAME="Adyen.xcodeproj"

# The top-level scheme that integrates/uses many Adyen frameworks.
# We'll start with "Adyen" as it succeeded manually.
TOP_LEVEL_BUILD_SCHEME="Adyen" # <-- Using "Adyen" as confirmed working.

# When -derivedDataPath and SYMROOT are not specified, xcodebuild uses defaults.
# Default DerivedData location is typically ~/Library/Developer/Xcode/DerivedData/
# Inside that, products for 'Release-iphoneos' will be:
# ~/Library/Developer/Xcode/DerivedData/<ProjectName-hash>/Build/Products/Release-iphoneos/
# We need to find this path dynamically, or rely on it being consistently structured.

# We'll use a placeholder for the output path for measuring.
# After a successful run, you'll need to inspect ~/Library/Developer/Xcode/DerivedData/
# to find the exact path to `Release-iphoneos` and adjust FRAMEWORKS_PRODUCT_PATH accordingly.
# For now, let's assume it's directly in ~/Library/Developer/Xcode/DerivedData/<ProjectName-hash>/Build/Products/Release-iphoneos/
# We'll use a dynamic way to find the latest DerivedData for measurement.

# A common name for the root of the derived data for the project
DERIVED_DATA_ROOT="${HOME}/Library/Developer/Xcode/DerivedData"

# This variable will be set after the build to the actual product path
ACTUAL_FRAMEWORKS_PRODUCT_PATH=""
ACTUAL_XCFRAMEWORKS_PRODUCT_PATH=""


# --- Pre-build Cleanup ---
echo "1. Performing cleanup..."
# Clean up Xcode's default DerivedData for this project to ensure a fresh build.
# This finds the specific DerivedData folder for your project.
echo "   Removing existing DerivedData for '${PROJECT_NAME}'..."
PROJECT_DERIVED_DATA_FOLDER_NAME=$(basename "${PROJECT_NAME}" .xcodeproj) # e.g., "Adyen"
# Find any folders matching pattern, allowing for the hash at the end
find "${DERIVED_DATA_ROOT}" -maxdepth 1 -type d -name "${PROJECT_DERIVED_DATA_FOLDER_NAME}-*" -print0 | while read -d $'\0' ddata_path; do
    echo "   Found and removing: ${ddata_path}"
    rm -rf "${ddata_path}"
done
echo "DerivedData cleanup complete."


# --- Build the top-level integrating scheme ---
# This command is taken directly from your manual working command.
# It uses Xcode's default DerivedData location.
echo "2. Building top-level scheme: ${TOP_LEVEL_BUILD_SCHEME} (using default DerivedData)..."

set +e # Temporarily disable exit on error

xcodebuild_command="xcodebuild clean build \
    -project \"${PROJECT_NAME}\" \
    -scheme \"${TOP_LEVEL_BUILD_SCHEME}\" \
    -sdk iphoneos \
    -configuration Release \
    -skipPackagePluginValidation \
    -verbose"
# REMOVED: SYMROOT and -derivedDataPath from here.
# Xcode will put intermediate files and final products in its default DerivedData.

# Execute the build command (full output to console and file)
echo "Executing build command (full output will be displayed):"
set -x # Re-enable set -x to see the command execution
eval "${xcodebuild_command}" 2>&1 | tee "${BUILD_OUTPUT_DIR}/full_build_log_${TOP_LEVEL_BUILD_SCHEME}.txt"
BUILD_STATUS=${PIPESTATUS[0]} # Get the exit status of xcodebuild (the first command in the pipe)
set +x # Disable tracing after the command executes
set -e

if [ ${BUILD_STATUS} -ne 0 ]; then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!! Build for scheme '${TOP_LEVEL_BUILD_SCHEME}' FAILED!   !!"
    echo "!! The exact command executed was:                        !!"
    echo "!! ${xcodebuild_command}                                  !!"
    echo "!! REVIEW THE FULL BUILD LOG ABOVE OR IN: ${BUILD_OUTPUT_DIR}/full_build_log_${TOP_LEVEL_BUILD_SCHEME}.txt !!"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit 1
fi
echo "Top-level scheme '${TOP_LEVEL_BUILD_SCHEME}' built successfully."

# --- Determine actual output paths after successful build ---
# This step finds the DerivedData folder created by xcodebuild and then the products within it.
echo "3. Locating built frameworks for measurement..."
set -x
# Find the latest DerivedData folder for your project
LATEST_PROJECT_DERIVED_DATA_FOLDER=$(find "${DERIVED_DATA_ROOT}" -maxdepth 1 -type d -name "${PROJECT_DERIVED_DATA_FOLDER_NAME}-*" -print0 | xargs -0 ls -td | head -n 1)

if [ -z "${LATEST_PROJECT_DERIVED_DATA_FOLDER}" ]; then
    echo "ERROR: Could not find the DerivedData folder for project ${PROJECT_NAME}."
    exit 1
fi

# Standard product path within DerivedData
ACTUAL_FRAMEWORKS_PRODUCT_PATH="${LATEST_PROJECT_DERIVED_DATA_FOLDER}/Build/Products/Release-iphoneos"
# Adjust for xcframeworks if they land in a different spot
ACTUAL_XCFRAMEWORKS_PRODUCT_PATH="${LATEST_PROJECT_DERIVED_DATA_FOLDER}/Build/Products/Release" # Common for xcframeworks

echo "   Detected framework products path: ${ACTUAL_FRAMEWORKS_PRODUCT_PATH}"
echo "   Detected xcframework products path: ${ACTUAL_XCFRAMEWORKS_PRODUCT_PATH}"
set +x


# --- Measure SDK and Frameworks ---
echo "4. Measuring SDK and Frameworks..." # Renumbered step

declare -A current_sizes_map # Associative array to store sizes

export -f measure_bundle_size
measure_bundle_size() {
    local bundle_path="$1"
    local bundle_type="$2"
    local bundle_name=$(basename "${bundle_path}" .${bundle_type})

    if [ -d "${bundle_path}" ]; then
        local bytes=$(du -sck "${bundle_path}" | grep total | awk '{print $1 * 1024}')
        local human_readable=$(numfmt --to=iec-bytes --format="%7.2f" "${bytes}")

        echo "   Found ${bundle_type}: ${bundle_name} - ${human_readable} (${bytes} bytes)"
        current_sizes_map["${bundle_name}"]="${human_readable}"
        current_sizes_map["${bundle_name}_bytes"]="${bytes}"
    else
        echo "   Warning: ${bundle_type} not found at path: ${bundle_path}. It might not be built or embedded by ${TOP_LEVEL_BUILD_SCHEME}."
        return 1
    fi
}

echo "   Searching for .framework bundles in ${ACTUAL_FRAMEWORKS_PRODUCT_PATH}..."
set -x
find "${ACTUAL_FRAMEWORKS_PRODUCT_PATH}" -maxdepth 1 -type d -name "*.framework" -print0 | \
    xargs -0 -I {} bash -c 'measure_bundle_size "$@" "framework"' _ {} \
    || { echo "Error measuring framework sizes!"; exit 1; }
set +x

echo "   Searching for .xcframework bundles in ${ACTUAL_XCFRAMEWORKS_PRODUCT_PATH}..."
set -x
find "${ACTUAL_XCFRAMEWORK_PRODUCT_PATH}" -maxdepth 1 -type d -name "*.xcframework" -print0 | \
    xargs -0 -I {} bash -c 'measure_bundle_size "$@" "xcframework"' _ {} \
    || { echo "Error measuring xcframework sizes!"; exit 1; }
set +x

echo ""
echo "--- Summary of Measured Framework Sizes ---"
if [ ${#current_sizes_map[@]} -eq 0 ]; then
    echo "No frameworks or xcframeworks were found in the build output."
    echo "Please inspect the contents of '${ACTUAL_FRAMEWORKS_PRODUCT_PATH}' and '${ACTUAL_XCFRAMEWORKS_PRODUCT_PATH}' after the script runs."
    echo "Also, review the full build log for ${TOP_LEVEL_BUILD_SCHEME} at '${BUILD_OUTPUT_DIR}/full_build_log_${TOP_LEVEL_BUILD_SCHEME}.txt' to understand why products were not found."
else
    FRAMEWORK_NAMES=()
    for key in "${!current_sizes_map[@]}"; do
        if [[ ! "$key" =~ _bytes$ ]]; then
            FRAMEWORK_NAMES+=("$key")
        fi
    done

    IFS=$'\n' sorted_frameworks=($(sort <<<"${FRAMEWORK_NAMES[*]}"))
    unset IFS

    echo "| Framework | Size     |"
    echo "|---|---|"
    for fw_name in "${sorted_frameworks[@]}"; do
        human_size="${current_sizes_map[${fw_name}]}"
        echo "| ${fw_name} | ${human_size} |"
    done

    JSON_OUTPUT="{"
    first=true
    for key in "${!current_sizes_map[@]}"; do
        if [[ $key == *_bytes ]]; then
            if [ "$first" = true ]; then
                first=false
            else
                JSON_OUTPUT+=","
            fi
            FRAMEWORK_NAME=$(echo "$key" | sed 's/_bytes//')
            JSON_OUTPUT+="\"${FRAMEWORK_NAME}\":${current_sizes_map[$key]}"
        fi
    done
    JSON_OUTPUT+="}"
    echo "$JSON_OUTPUT" > "${BUILD_OUTPUT_DIR}/sdk_sizes_current.json"
    echo ""
    echo "Raw byte sizes saved to: ${BUILD_OUTPUT_DIR}/sdk_sizes_current.json"
fi

echo ""
echo "--- Local SDK Size Analysis Script Finished ---"
echo "You can inspect the generated files in: ${BUILD_OUTPUT_DIR}"