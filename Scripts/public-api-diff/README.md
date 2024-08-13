# Swift Public API diff

This tool allows comparing 2 versions of a swift package project and lists all changes in a human readable way.

It makes use of `xcrun swift-api-digester -dump-sdk` to create a dump of the public api of your swift package and then runs it through a custom parser to process them.

Alternatively you could use `xcrun --sdk iphoneos swift-api-digester -diagnose-sdk` and pass the abi dumps into it.

## How it works

### Pipeline

### Consolidating Changes
