#!/bin/sh

YELLOW='\033[1;33m'
NOCOLOR='\033[0m'
RED='\033[0;31m'

OUT_PUT_FILE_NAME=temp_file

rm $OUT_PUT_FILE_NAME

touch $OUT_PUT_FILE_NAME

echo "false" > $OUT_PUT_FILE_NAME

function processOutPut() {
  while read -r line
   do
     if [[ $line = *"Test"* ]]; then
       echo "${YELLOW}$line${NOCOLOR}"
     elif [[ $line == *"warning"* ]]; then
       echo "${RED}$line${NOCOLOR}"
       echo "true" > $1
     elif [[ $line != *"no typo!"* ]]; then
       echo "$line"
     fi
  done
}

function escapePath() {
  echo $( echo "$1" | sed 's/ /\\ /g' )
}

set -e

export PATH=~/.mint/bin:$PATH

mint install fromkk/SpellChecker@0.1.0 SpellChecker

IFS=$'\n'
files="$(git diff origin/$target_branch HEAD --name-only -- "*.swift")"
declare -p -a files

excludedFiles="$(cat spell-check-excluded-files-list)"
declare -a excludedFiles

for file in $files
do
  isIncluded=true
  for excludedFile in $excludedFiles
  do
    if [[ "$file" == *"$excludedFile"* ]]; then
      isIncluded=false
    fi
  done
  if [[ $isIncluded == true ]]; then
    /Users/runner/.mint/bin/SpellChecker --yml spell-check-word-allow-list.yaml -- $file | processOutPut $OUT_PUT_FILE_NAME
  fi
done



SHOULD_FAIL=$(cat $OUT_PUT_FILE_NAME)

rm $OUT_PUT_FILE_NAME

if [ "$SHOULD_FAIL" = true ]; then
  exit 1
fi
