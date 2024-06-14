#!/usr/bin/env xcrun swift

import Foundation

///Parse Package.swift file and add a new library to the list of products that contains all targets

// MARK: - Convenience Methods

func availableTargets(from packageContent: String) -> [String] {
    let scanner = Scanner(string: packageContent)
    _ = scanner.scanUpTo("targets: [", into: nil)

    var availableTargets = Set<String>()

    while scanner.scanUpTo(".target(", into: nil) {
        let nameStartTag = "name: \""
        let nameEndTag = "\""
        
        scanner.scanUpTo(nameStartTag, into: nil)
        scanner.scanString(nameStartTag, into: nil)
        
        var targetName: NSString?
        scanner.scanUpTo(nameEndTag, into: &targetName)
        if let targetName = targetName as? String {
            availableTargets.insert(targetName)
        }
    }
    
    return availableTargets.sorted()
}

func consolidatedLibraryEntry(_ name: String, from availableTargets: [String]) -> String {
"""

        .library(
            name: "\(name)",
            targets: [\(availableTargets.map { "\"\($0)\"" }.joined(separator: ", "))]
        ),
"""
}

func updatedContent(with consolidatedEntry: String) -> String {
    // Update the Package.swift content
    var updatedContent = packageContent
    if let productsRange = packageContent.range(of: "products: [", options: .caseInsensitive) {
        updatedContent.insert(contentsOf: consolidatedEntry, at: productsRange.upperBound)
    } else {
        print("Products section not found")
    }
    return updatedContent
}

// MARK: - Main

let packagePath = CommandLine.arguments[1] // Path to the Package.swift file
let consolidatedLibraryName = CommandLine.arguments[2] // Name of the library containing all targets

let packageContent = try String(contentsOfFile: packagePath)
let targets = availableTargets(from: packageContent)
let consolidatedEntry = consolidatedLibraryEntry(consolidatedLibraryName, from: targets)
let updatedPackageContent = updatedContent(with: consolidatedEntry)

// Write the updated content back to the file
try updatedPackageContent.write(toFile: packagePath, atomically: true, encoding: .utf8)
