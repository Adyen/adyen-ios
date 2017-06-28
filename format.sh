#!/bin/bash

echo "Formatting..."

./Example/1-quick-integration-example/Pods/SwiftFormat/CommandLineTool/swiftformat Adyen/ Example/ \
    --disable blankLinesAtEndOfScope,unusedArguments \
    --comments ignore \
    --commas inline \
    --ranges nospace \
    --trimwhitespace nonblank-lines \
    --decimalgrouping none \
    --header "\n Copyright (c) {year} Adyen B.V.\n\n This file is open source and available under the MIT license. See the LICENSE file for more info.\n"
