#!/bin/bash

PROJECT_NAME=TempProject

# Clean up.
rm -rf $PROJECT_NAME

mkdir -p $PROJECT_NAME && cd $PROJECT_NAME

# Create the project.
swift package init
swift package generate-xcodeproj

# Create the Cartfile.
CWD=$(pwd)
CURRENT_BRANCH=$(git branch --show-current)
echo "git \"file:///$CWD/../\" \"$CURRENT_BRANCH\"" > Cartfile

carthage update

xcodebuild archive -scheme TempProject-Package -destination 'generic/platform=iOS'

xcodebuild archive -scheme TempProject-Package -destination 'generic/platform=iOS Simulator' ARCHS=i386

xcodebuild archive -scheme TempProject-Package -destination 'generic/platform=iOS Simulator' ARCHS=x86_64

# Clean up.
cd ../
rm -rf $PROJECT_NAME
