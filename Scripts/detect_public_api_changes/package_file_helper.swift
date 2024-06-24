#!/usr/bin/env xcrun swift

//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

// MARK: - Convenience Methods

/// Extracts all targets in the targets section
///
/// Returns: All available target names
func availableTargets(from packageContent: String) -> [String] {
    let scanner = Scanner(string: packageContent)
    _ = scanner.scanUpToString("targets: [")

    var availableTargets = Set<String>()

    while scanner.scanUpToString(".target(") != nil {
        let nameStartTag = "name: \""
        let nameEndTag = "\""
        
        _ = scanner.scanUpToString(nameStartTag)
        _ = scanner.scanString(nameStartTag)
        
        if let targetName = scanner.scanUpToString(nameEndTag) {
            availableTargets.insert(targetName)
        }
    }
    
    return availableTargets.sorted()
}

/// Generates a library entry from the name and available target names to be inserted into the `Package.swift` file
func consolidatedLibraryEntry(_ name: String, from availableTargets: [String]) -> String {
    """

            .library(
                name: "\(name)",
                targets: [\(availableTargets.map { "\"\($0)\"" }.joined(separator: ", "))]
            ),
    """
}

/// Generates the updated content for the `Package.swift` adding the consolidated library entry (containing all targets) in the products section
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
let packageContent = try String(contentsOfFile: packagePath)
let targets = availableTargets(from: packageContent)

if CommandLine.arguments[2] == "-add-consolidated-library" {
    // Inserts a new library into the targets section containing all targets from the target section
    let consolidatedLibraryName = CommandLine.arguments[3] // Name of the library containing all targets
    let consolidatedEntry = consolidatedLibraryEntry(consolidatedLibraryName, from: targets)
    let updatedPackageContent = updatedContent(with: consolidatedEntry)
    // Write the updated content back to the file
    try updatedPackageContent.write(toFile: packagePath, atomically: true, encoding: .utf8)
} else if CommandLine.arguments[2] == "-print-available-targets" {
    // Prints the targets to the console so it can be consumed by the "compare.sh" script and transformed in to an array
    print(targets.joined(separator: " "))
}
