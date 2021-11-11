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
     else
       echo "$line"
     fi
  done
}

export PATH=~/.mint/bin:$PATH

mint install ezura/spell-checker-for-swift@5.3.0

typokana | processOutPut $OUT_PUT_FILE_NAME

SHOULD_FAIL=$(cat $OUT_PUT_FILE_NAME)

rm $OUT_PUT_FILE_NAME

if [ "$SHOULD_FAIL" = true ]; then
  exit 1
fi
