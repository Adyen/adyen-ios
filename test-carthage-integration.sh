#!/bin/bash

PROJECT_NAME=TempProject

# Clean up.
rm -rf $PROJECT_NAME

mkdir -p $PROJECT_NAME && cd $PROJECT_NAME

# Create the Cartfile.
CWD=$(pwd)
CURRENT_COMMIT=$(git rev-parse HEAD)
echo "git \"file:///$CWD/../\" \"$CURRENT_COMMIT\"" > Cartfile

# ../carthage.sh update
../carthage.sh update --platform iOS

# Clean up.
cd ../
rm -rf $PROJECT_NAME
