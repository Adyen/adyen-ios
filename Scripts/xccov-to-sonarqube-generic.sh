#!/usr/bin/env bash

# File used for converting Xcode coverage reports into a format consumable by SonarQube
# https://github.com/SonarSource/sonar-scanning-examples/tree/master/swift-coverage
# https://github.com/SonarSource/sonar-scanning-examples/blob/master/swift-coverage/swift-coverage-example/xccov-to-sonarqube-generic.sh

set -euo pipefail

function convert_file {
  local xccovarchive_file="$1"
  local file_name="$2"
  local xccov_options="$3"
  echo "  <file path=\"$file_name\">"
  xcrun xccov view $xccov_options --file "$file_name" "$xccovarchive_file" | \
    sed -n '
    s/^ *\([0-9][0-9]*\): 0.*$/    <lineToCover lineNumber="\1" covered="false"\/>/p;
    s/^ *\([0-9][0-9]*\): [1-9].*$/    <lineToCover lineNumber="\1" covered="true"\/>/p
    '
  echo '  </file>'
} 

function xccov_to_generic {
  echo '<coverage version="1">'
  for xccovarchive_file in "$@"; do
    if [[ ! -d $xccovarchive_file ]]
    then
      echo "Coverage FILE NOT FOUND AT PATH: $xccovarchive_file" 1>&2;
      exit 1
    fi
    
    local xccov_options=""
    if [[ $xccovarchive_file == *".xcresult"* ]]; then
      xccov_options="--archive"
    fi
    xcrun xccov view $xccov_options --file-list "$xccovarchive_file" | while read -r file_name; do
      convert_file "$xccovarchive_file" "$file_name" "$xccov_options"
    done
  done
  echo '</coverage>'
}

function cleanup_tmp_files {
  rm -rf tmp.json
  rm -rf tmp.xccovarchive
}

xccov_to_generic "$@"
cleanup_tmp_files
