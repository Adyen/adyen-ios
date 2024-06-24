#!/bin/bash

# -------------------------------------------------------------------
# Setup & Info
# -------------------------------------------------------------------

BRANCH=$1
REPO=$2
TARGET="x86_64-apple-ios17.4-simulator"
SDK="`xcrun --sdk iphonesimulator --show-sdk-path`"
COMPARISON_VERSION_DIR_NAME="comparison_version_$BRANCH"
DERIVED_DATA_PATH=".build"
SDK_DUMP_INPUT_PATH="$DERIVED_DATA_PATH/Build/Products/Debug-iphonesimulator"
ALL_TARGETS_LIBRARY_NAME="AdyenAllTargets"
MODULE_NAMES=($(./Scripts/detect_public_api_changes/package_file_helper.swift Package.swift -print-available-targets))

# -------------------------------------------------------------------
# Convenience Functions
# -------------------------------------------------------------------

# Echos the entered information for validation
function printRunInfo() {

    echo "Branch: " $BRANCH
    echo "Repo:   " $REPO
    echo "Target: " $TARGET
    echo "Dir:    " $COMPARISON_VERSION_DIR_NAME

    echo "Modules:"
    for MODULE in ${MODULE_NAMES[@]}; do
        echo "-" $MODULE
    done
}

# Clones the comparison project into a custom directory
function setupComparisonRepo() {

    rm -rf $COMPARISON_VERSION_DIR_NAME
    mkdir $COMPARISON_VERSION_DIR_NAME
    cd $COMPARISON_VERSION_DIR_NAME
    git clone -b $BRANCH $REPO
    cd ..
}

# Builds the project and temporarily modifies
# some files to optimize the process
#
# $1 - The path to the current project dir
#
# Examples
#
#  buildProject . # If we're in the current project dir
#  buildProject ../.. # If we're in the comparison project dir
function buildProject() {

    # Removing derived data if available
    rm -rf .build

    # We have to obscure the project file so `xcodebuild` uses the Package.swift to build the module
    mv Adyen.xcodeproj Adyen.xcode_proj
    
    # Copying the Package.swift so we can revert the change done by the next step
    cp Package.swift Package.sw_ift
    
    # Modify the Package.swift file to generate a product/library that contains all targets
    # so we only have to build it once and can use it to diff all modules
    $1/Scripts/detect_public_api_changes/package_file_helper.swift Package.swift -add-consolidated-library $ALL_TARGETS_LIBRARY_NAME

    xcodebuild -scheme $ALL_TARGETS_LIBRARY_NAME \
    -sdk $SDK \
    -derivedDataPath $DERIVED_DATA_PATH \
    -destination "platform=iOS,name=Any iOS Device" \
    -target $TARGET \
    -quiet \
    -skipPackagePluginValidation
    
    # Reverting the tmp changes
    rm Package.swift
    mv Adyen.xcode_proj Adyen.xcodeproj
    mv Package.sw_ift Package.swift
}

# Generates an sdk-dump in form of a json file
#
# $1 - The module to generate the dump for
# $2 - The output path for the generated json file
#
# Examples
#
#  generateSdkDump "AdyenDropIn" "api_dump.json"
#
function generateSdkDump() {

    xcrun swift-api-digester -dump-sdk \
     -module $1 \
     -o $2 \
     -I $SDK_DUMP_INPUT_PATH \
     -sdk $SDK \
     -target $TARGET
}

# Compares both versions of the provided module
# and writes the result into a .md file (Handled by the diff.swift script)
#
# $1 - The module to compare
#
# Examples
#
#  diffModuleVersions "AdyenDropIn"
#
function diffModuleVersions() {

    echo "📋 [$1] Generating current sdk dump"
    generateSdkDump $1 "api_dump.json"

    cd $COMPARISON_VERSION_DIR_NAME/adyen-ios

    echo "📋 [$1] Generating comparison sdk dump"
    generateSdkDump $1 "../../api_dump_comparison.json"

    cd ../..
    
    ./Scripts/detect_public_api_changes/diff.swift "api_dump_comparison.json" "api_dump.json" $1
    
    # Cleaning up afterwards
    rm api_dump.json
    rm api_dump_comparison.json
}

# -------------------------------------------------------------------
# Main Execution
# -------------------------------------------------------------------

printRunInfo

echo "↘️  Setting up comparison project"
setupComparisonRepo

# Move into the comparison project
cd $COMPARISON_VERSION_DIR_NAME/adyen-ios

echo "🛠️  Building '$ALL_TARGETS_LIBRARY_NAME' comparison project"
buildProject ../..

# Move back to the current project dir
cd ../..

echo "🛠️  Building '$ALL_TARGETS_LIBRARY_NAME' current project"
buildProject .

echo "👷 Diffing all Modules"

for MODULE in ${MODULE_NAMES[@]}; do

diffModuleVersions $MODULE

done
