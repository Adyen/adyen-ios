#!/bin/bash

LATEST_TAG=$(git describe --tags --abbrev=0)
NUMBER_OF_COMMITS_SINCE_LAST_RELEASE=$(git log --oneline $LATEST_TAG..HEAD | wc -l | sed 's/^ *//g' | sed 's/ *$//g')
CMD="git log -$NUMBER_OF_COMMITS_SINCE_LAST_RELEASE"
eval $CMD | awk '/<p>/,/<\/p>/'