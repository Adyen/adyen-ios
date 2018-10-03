#!/bin/bash

echo "Formatting..."

./Pods/SwiftFormat/CommandLineTool/swiftformat ./ \
    --disable blankLinesAtStartOfScope,blankLinesAtEndOfScope,unusedArguments,redundantSelf \
    --comments ignore \
    --commas inline \
    --ranges nospace \
    --trimwhitespace nonblank-lines \
    --decimalgrouping none \
    --header "\nCopyright (c) {year} Adyen B.V.\n\nThis file is open source and available under the MIT license. See the LICENSE file for more info.\n"
