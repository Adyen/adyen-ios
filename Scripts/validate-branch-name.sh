#!/bin/sh
LC_ALL=C

local_branch="$(git rev-parse --abbrev-ref HEAD)"

valid_branch_regex="^(feature|fix|chore|improvement|release)\/[a-z0-9._-]+$"

message="Invalid branch name. Branch names should follow this format: $valid_branch_regex. Your commit will be rejected. Rename your branch to a valid name and try again."

if [[ ! $local_branch =~ $valid_branch_regex ]]
then
    echo "$message"
    exit 1
fi

exit 0
