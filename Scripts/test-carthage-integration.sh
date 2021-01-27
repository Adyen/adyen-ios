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
git \"file:///$CWD/../\" \"$CURRENT_COMMIT\"
github \"ReactiveCocoa/ReactiveSwift\" ~> 4.0
" > Cartfile

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
      - carthage: CarthageTestFixture
  Tests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - Tests/
    dependencies:
      - target: Framework
    
" > project.yml

pwd
mv ../Tests/AdyenWeChatTests/AdyenWeChatTests.swift Tests/Tests.swift

xcodegen generate

# ../carthage.sh update
../carthage.sh update

# Clean up.
cd ../
rm -rf $PROJECT_NAME
