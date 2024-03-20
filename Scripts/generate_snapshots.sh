#!/bin/bash

# Deleting all existing snapshots
echo "🗑️  Deleting existing Snapshots"
find ./UITests -name "__Snapshots__" -exec rm -rf {} +

# Generating snapshots for iPhone
echo "🤳 Generating Snapshots"
xcodebuild test -project Adyen.xcodeproj -scheme 'GenerateSnapshots' -destination "name=iPhone 15 Pro,OS=17.4" -destination "name=iPad Pro (12.9-inch) (6th generation),OS=17.4"
