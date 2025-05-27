#!/bin/zsh
set -eo pipefail

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# ----------------------------
# CLI Argument Parsing
# ----------------------------

SKIP_BUILD="${SKIP_BUILD:-false}"  # default false
JSON_PRETTY=false

for arg in "$@"; do
  case $arg in
    --skip-build)
      SKIP_BUILD=true
      shift
      ;;
    --json-pretty)
      JSON_PRETTY=true
      shift
      ;;
    *)
      echo "❗ Unknown option: $arg"
      echo "Usage: $0 [--skip-build] [--json-pretty]"
      exit 1
      ;;
  esac
done

echo "--- Starting Local SDK Size Analysis Script ---"

# ----------------------------
# Config
# ----------------------------

PROJECT_NAME="Adyen.xcodeproj"
TOP_LEVEL_SCHEME="AdyenUIHost"
BUILD_CONFIGURATION="Release"
BUILD_OUTPUT_DIR="${PWD}/sdk_size_output"

# ----------------------------
# Helpers
# ----------------------------

print_step() {
  echo
  echo "🔹 $1"
}

human_readable_size() {
  local size_kb=$1
  if (( size_kb >= 1024 )); then
    echo "$(echo "scale=1; $size_kb / 1024" | bc)MB"
  else
    echo "${size_kb}KB"
  fi
}

# ----------------------------
# Resolve DerivedData path
# ----------------------------

print_step "Resolving DerivedData path..."
DERIVED_DATA_PATH=$(xcodebuild -project "$PROJECT_NAME" -scheme "$TOP_LEVEL_SCHEME" -showBuildSettings | grep -m1 -oE '(/.*DerivedData[^ ]*)')
FRAMEWORKS_PRODUCT_PATH="${DERIVED_DATA_PATH}/${BUILD_CONFIGURATION}-iphoneos"

mkdir -p "$BUILD_OUTPUT_DIR"

echo "DerivedData path: ${DERIVED_DATA_PATH}"
echo "Framework product path: ${FRAMEWORKS_PRODUCT_PATH}"

# ----------------------------
# Clean and Build
# ----------------------------

if [[ "$SKIP_BUILD" == "true" ]]; then
  echo "⚠️  Skipping build step (--skip-build enabled)"
else
  print_step "Cleaning DerivedData..."
  rm -rf "${DERIVED_DATA_PATH}"

  print_step "Building scheme: $TOP_LEVEL_SCHEME"
  set +e
  xcodebuild clean build \
    -project "${PROJECT_NAME}" \
    -scheme "${TOP_LEVEL_SCHEME}" \
    -sdk iphoneos \
    -configuration "${BUILD_CONFIGURATION}" \
    -skipPackagePluginValidation \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    2>&1 | tee "${BUILD_OUTPUT_DIR}/build_log_${TOP_LEVEL_SCHEME}.txt"
  BUILD_STATUS=${pipestatus[1]}
  set -e

  if [[ $BUILD_STATUS -ne 0 ]]; then
    echo "❌ Build failed for scheme '${TOP_LEVEL_SCHEME}'"
    exit 1
  fi

  echo "✅ Build succeeded for '${TOP_LEVEL_SCHEME}'"
fi

# ----------------------------
# Analyze Framework Sizes
# ----------------------------

print_step "Calculating framework sizes..."

typeset -A framework_map
total_kb=0

framework_paths=($(find "$FRAMEWORKS_PRODUCT_PATH" -name "*.framework" -type d))

for framework_path in $framework_paths; do
  name=$(basename "$framework_path")
  size_kb=$(find "$framework_path" -type f -exec stat -f%z {} + | awk '{s+=$1} END {print int(s/1024)}')
  framework_map[$name]=$size_kb
done

# Print
for name in ${(k)framework_map}; do
  size_kb=${framework_map[$name]}
  (( total_kb += size_kb ))
  formatted=$(human_readable_size "$size_kb")
  printf "%-50s %8s\n" "$name" "$formatted"
done

# Print total
echo "-------------------------------------"
formatted_total=$(human_readable_size "$total_kb")
printf "%-50s %8s\n" "TOTAL" "$formatted_total"

# ----------------------------
# Export to Valid Pretty JSON
# ----------------------------

print_step "Writing sdk_sizes.json..."

json_path="${BUILD_OUTPUT_DIR}/sdk_sizes.json"

# Build raw JSON content
raw_json="{"
first=true
for name in ${(k)framework_map}; do
  size_kb=${framework_map[$name]}
  if $first; then
    first=false
  else
    raw_json+=", "
  fi
  raw_json+="\"${name}\": ${size_kb}"
done
raw_json+=", \"__total__\": ${total_kb}}"

# Prettify using jq
echo "$raw_json" | jq '.' > "$json_path"

echo "Saved to: $json_path"
