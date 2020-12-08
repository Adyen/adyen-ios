#!/bin/bash

set -e # Any subsequent(*) commands which fail will cause the shell script to exit immediately

PROJECT_NAME=TempProject

# Clean up.
rm -rf $PROJECT_NAME

mkdir -p $PROJECT_NAME && cd $PROJECT_NAME

# Create the Cartfile.
CWD=$(pwd)
CURRENT_COMMIT=$(git rev-parse HEAD)
echo "git \"file:///$CWD/../\" \"$CURRENT_COMMIT\"" > Cartfile

# ../carthage.sh update
../carthage.sh update

# Clean up.
cd ../
rm -rf $PROJECT_NAME
