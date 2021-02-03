#!/bin/bash

set -e # Any subsequent(*) commands which fail will cause the shell script to exit immediately

PROJECT_NAME=TempProject

# Clean up.
rm -rf $PROJECT_NAME

mkdir -p $PROJECT_NAME && cd $PROJECT_NAME

# Create the Cartfile.
CWD=$(pwd)
CURRENT_COMMIT=$(git rev-parse HEAD)
echo "
git \"file://$CWD/../\" \"$CURRENT_COMMIT\"
" > Cartfile

echo " === Carthage update"
../Scripts/carthage.sh update

# Setup Project
echo "
name: $PROJECT_NAME
options:
  findCarthageFrameworks: true
targets:
  Framework:
    type: framework
    platform: iOS
    dependencies:
      - carthage: adyen
  Tests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - Tests/
    dependencies:
      - target: Framework

" > project.yml

mkdir Tests
mv "../Tests/AdyenTests/Adyen Tests/Components/AdyenActionHandlerTests.swift" Tests/Tests.swift

xcodegen generate

# Run Tests
xcodebuild build test -project TempProject.xcodeproj -scheme Tests | xcpretty && exit ${PIPESTATUS[0]}

# Clean up.
cd ../
rm -rf $PROJECT_NAME
