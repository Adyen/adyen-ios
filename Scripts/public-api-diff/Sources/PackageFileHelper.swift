//
//  PackageFileHelper.swift
//  
//
//  Created by Alexander Guretzki on 17/06/2024.
//

import Foundation

struct PackageFileHelper {
    
    let packagePath: String
    
    private var packageBackupPath: String {
        packagePath.appending("_old")
    }
    
    init(packagePath: String) {
        self.packagePath = packagePath
    }
    
    func availableTargets() throws -> [String] {
        
        let packageContent = try String(contentsOfFile: packagePath)
        return try availableTargets(from: packageContent)
    }
    
    /// Inserts a new library into the targets section containing all targets from the target section
    func preparePackageWithConsolidatedLibrary(
        named consolidatedLibraryName: String
    ) throws {
        
        let packageContent = try String(contentsOfFile: packagePath)
        
        // Making a backup of the current Package.swift file
        try packageContent.write(toFile: packageBackupPath, atomically: true, encoding: .utf8)
        let targets = try availableTargets(from: packageContent)
        
        let consolidatedEntry = consolidatedLibraryEntry(consolidatedLibraryName, from: targets)
        let updatedPackageContent = updatedContent(packageContent, with: consolidatedEntry)
        
        // Write the updated content back to the file
        try updatedPackageContent.write(toFile: packagePath, atomically: true, encoding: .utf8)
    }
    
    func revertPackageChanges() throws {
        
        let backupContent = try String(contentsOfFile: packageBackupPath)
        try backupContent.write(toFile: packagePath, atomically: true, encoding: .utf8)
        try FileManager.default.removeItem(atPath: packageBackupPath)
    }
}

// MARK: - Privates

private extension PackageFileHelper {
    
    /// Generates a library entry from the name and available target names to be inserted into the `Package.swift` file
    func consolidatedLibraryEntry(
        _ name: String,
        from availableTargets: [String]
    ) -> String {
    """

            .library(
                name: "\(name)",
                targets: [\(availableTargets.map { "\"\($0)\"" }.joined(separator: ", "))]
            ),
    """
    }
    
    /// Generates the updated content for the `Package.swift` adding the consolidated library entry (containing all targets) in the products section
    func updatedContent(
        _ packageContent: String,
        with consolidatedEntry: String
    ) -> String {
        // Update the Package.swift content
        var updatedContent = packageContent
        if let productsRange = packageContent.range(of: "products: [", options: .caseInsensitive) {
            updatedContent.insert(contentsOf: consolidatedEntry, at: productsRange.upperBound)
        } else {
            print("Products section not found")
        }
        return updatedContent
    }
    
    func availableTargets(from packageContent: String) throws -> [String] {
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
}
