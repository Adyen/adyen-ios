#!/bin/sh
LC_ALL=C

local_branch="$(git rev-parse --abbrev-ref HEAD)"

valid_branch_regex="^(feature|fix|chore|improvement|release)\/[a-zA-Z0-9._-]+$"

message="Invalid branch name. Branch names should follow this format: $valid_branch_regex. Rename your branch to a valid name (e.g., \"feature/payto-base\", \"fix/card-number-validation\", \"release/5.5.5\") and try again."

if [[ ! $local_branch =~ $valid_branch_regex ]]
then
    echo "$message"
    exit 1
fi

exit 0
