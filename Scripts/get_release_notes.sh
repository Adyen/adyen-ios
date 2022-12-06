#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'
FILE_NAME=.pull-requests-allowed-labels-list
FILE_PATH=./$FILE_NAME
if [[ ! -f "$FILE_PATH" ]]; then
    echo -e "${RED}$FILE_NAME file doesn't exits in the root of the respository${NC}"
    exit 1
fi  

LATEST_TAG=$(git describe --tags --abbrev=0)
NUMBER_OF_COMMITS_SINCE_LAST_RELEASE=$(git log --oneline $LATEST_TAG..HEAD | wc -l | sed 's/^ *//g' | sed 's/ *$//g')

ALLOWED_LABELS_ARRAY=($(cat $FILE_PATH | sed 's/,/ /g'))

for LABEL in "${ALLOWED_LABELS_ARRAY[@]}"; do
   CMD="git log -$NUMBER_OF_COMMITS_SINCE_LAST_RELEASE"
   CMD="$CMD | awk '/$LABEL\s*:?\s*<p>/,/<\/p>/'"
   eval $CMD
done

