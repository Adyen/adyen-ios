//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct PackageFileHelper {
    
    private let packagePath: String
    private let fileHandler: FileHandling
    
    init(
        packagePath: String,
        fileHandler: FileHandling
    ) {
        self.packagePath = packagePath
        self.fileHandler = fileHandler
    }
    
    static func packagePath(for projectDirectoryPath: String) -> String {
        projectDirectoryPath.appending("/Package.swift")
    }
    
    func availableTargets() throws -> Set<String> {
        
        // TODO: Better use "swift package describe --type json" instead of trying to parse the Package.swift file itself
        let packageContent = try fileHandler.load(from: packagePath)
        return availableTargets(from: packageContent)
    }
    
    func availableProducts() throws -> Set<String> {
        
        // TODO: Better use "swift package describe --type json" instead of trying to parse the Package.swift file itself
        let packageContent = try fileHandler.load(from: packagePath)
        return availableProducts(from: packageContent)
    }
    
    /// Inserts a new library into the targets section containing all targets from the target section
    func preparePackageWithConsolidatedLibrary(
        named consolidatedLibraryName: String
    ) throws {
        
        let packageContent = try fileHandler.load(from: packagePath)
        let targets = availableTargets(from: packageContent)
        
        let consolidatedEntry = consolidatedLibraryEntry(consolidatedLibraryName, from: targets.sorted())
        let updatedPackageContent = updatedContent(packageContent, with: consolidatedEntry)
        
        // Write the updated content back to the file
        try fileHandler.write(updatedPackageContent, to: packagePath)
    }
}

extension PackageFileHelper {
    
    static func availableTargets(
        oldProjectDirectoryPath: String,
        newProjectDirectoryPath: String,
        fileHandler: FileHandling
    ) throws -> [String] {
        
        let oldPackagePath = packagePath(for: oldProjectDirectoryPath)
        let newPackagePath = packagePath(for: newProjectDirectoryPath)
        
        let oldTargets = try Self(
            packagePath: oldPackagePath,
            fileHandler: fileHandler
        ).availableTargets()
        
        let newTargets = try Self(
            packagePath: newPackagePath,
            fileHandler: fileHandler
        ).availableTargets()
        
        return oldTargets.union(newTargets).sorted()
    }
}

// MARK: - Privates

// MARK: Extract Targets/Products

private extension PackageFileHelper {
    
    enum TargetType {
        case target
        case binaryTarget
        
        var startTag: String {
            switch self {
            case .target:
                ".target("
            case .binaryTarget:
                ".binaryTarget("
            }
        }
    }
    
    func availableTargets(from packageContent: String) -> Set<String> {
        let targets = availableTargets(from: packageContent, ofType: .target)
        let binaryTargets = availableTargets(from: packageContent, ofType: .binaryTarget)
        
        // Removing binaryTargets from list of targets as we can't generate an sdk dump for them
        return targets.subtracting(binaryTargets)
    }
    
    func availableTargets(from packageContent: String, ofType targetType: TargetType) -> Set<String> {
        // TODO: Better use "swift package describe --type json" instead of trying to parse the Package.swift file itself
        let scanner = Scanner(string: packageContent)
        _ = scanner.scanUpToString("targets: [")

        var availableTargets = Set<String>()

        while scanner.scanUpToString(targetType.startTag) != nil {
            let nameStartTag = "name: \""
            let nameEndTag = "\""
            
            _ = scanner.scanUpToString(nameStartTag)
            _ = scanner.scanString(nameStartTag)
            
            if let targetName = scanner.scanUpToString(nameEndTag) {
                availableTargets.insert(targetName)
            }
        }
        
        return availableTargets
    }
    
    func availableProducts(from packageContent: String) -> Set<String> {
        // TODO: Better use "swift package describe --type json" instead of trying to parse the Package.swift file itself
        let scanner = Scanner(string: packageContent)
        _ = scanner.scanUpToString("products: [")

        var availableProducts = Set<String>()

        while scanner.scanUpToString(".library(") != nil {
            let nameStartTag = "name: \""
            let nameEndTag = "\""
            
            _ = scanner.scanUpToString(nameStartTag)
            _ = scanner.scanString(nameStartTag)
            
            if let targetName = scanner.scanUpToString(nameEndTag) {
                availableProducts.insert(targetName)
            }
        }
        
        return availableProducts
    }
}

// MARK: Update Package Content

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
}
