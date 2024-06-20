//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

// MARK: - Model

enum SDKAnalyzer {
    
    public static func analyze(
        old oldProjectDirectoryPath: String,
        new newProjectDirectoryPath: String
    ) throws -> [String: [SDKAnalyzer.Change]] {
        print("🔍 Scanning for products changes")
        
        let packageFileChanges = try SDKAnalyzer.analyzePackageFile(
            updated: PackageFileHelper.packagePath(for: newProjectDirectoryPath),
            to: PackageFileHelper.packagePath(for: oldProjectDirectoryPath)
        )
        
        print("🔍 Scanning for breaking API changes")
        
        let allTargets = try PackageFileHelper.availableTargets(
            oldProjectDirectoryPath: oldProjectDirectoryPath,
            newProjectDirectoryPath: newProjectDirectoryPath
        )
        
        var changesPerTarget = try SDKAnalyzer.analyzeSdkDump(
            for: allTargets,
            currentSdkDumpGenerator: .init(projectDirectoryPath: newProjectDirectoryPath),
            comparisonSdkDumpGenerator: .init(projectDirectoryPath: oldProjectDirectoryPath)
        )
        
        if !packageFileChanges.isEmpty {
            changesPerTarget["Package.swift"] = (changesPerTarget["Package.swift"] ?? []) + packageFileChanges
        }
        
        return changesPerTarget
    }
    
    private static func analyzePackageFile(
        updated updatedPackageFilePath: String,
        to comparisonPackageFilePath: String
    ) throws -> [Change] {
        var libraryChanges = [Change]()
        
        let comparisonProducts = try PackageFileHelper(packagePath: comparisonPackageFilePath).availableProducts()
        let currentProducts = try PackageFileHelper(packagePath: updatedPackageFilePath).availableProducts()
        
        let removedLibaries = comparisonProducts.subtracting(currentProducts)
        libraryChanges += removedLibaries.map {
            .init(
                changeType: .removal,
                parentName: "",
                changeDescription: "`.library(name: \"\($0)\", ...)` was removed"
            )
        }
        
        let addedLibraries = currentProducts.subtracting(comparisonProducts)
        libraryChanges += addedLibraries.map {
            .init(
                changeType: .addition,
                parentName: "",
                changeDescription: "`.library(name: \"\($0)\", ...)` was added"
            )
        }
        
        return libraryChanges
    }
    
    private static func analyzeSdkDump(
        for allTargets: [String],
        currentSdkDumpGenerator: SDKDumpGenerator,
        comparisonSdkDumpGenerator: SDKDumpGenerator
    ) throws -> [String: [SDKAnalyzer.Change]] {
        
        var changesPerTarget = [String: [SDKAnalyzer.Change]]() // [ModuleName: [SDKDumpAnalyzer.Change]]
        
        try allTargets.forEach { targetName in
            let currentSdkDumpFilePath = currentSdkDumpGenerator.generate(for: targetName)
            let comparisonSdkDumpFilePath = comparisonSdkDumpGenerator.generate(for: targetName)
            
            let diff = try SDKAnalyzer.diffSdkDump(
                updated: currentSdkDumpFilePath,
                to: comparisonSdkDumpFilePath
            )
            
            if !diff.isEmpty { changesPerTarget[targetName] = diff }
        }
        
        return changesPerTarget
    }
    
    private static func diffSdkDump(
        updated updatedSdkDumpFilePath: String,
        to comparisonSdkDumpFilePath: String
    ) throws -> [Change] {
        
        let decodedComparisonDump = load(from: comparisonSdkDumpFilePath)
        let decodedUpdatedDump = load(from: updatedSdkDumpFilePath)
        
        guard decodedComparisonDump != decodedUpdatedDump else {
            return []
        }
        
        guard let decodedUpdatedDump else {
            return [.init(changeType: .removal, parentName: "", changeDescription: "Target was removed")]
        }
        
        guard let decodedComparisonDump else {
            return [.init(changeType: .addition, parentName: "", changeDescription: "Target was added")]
        }
        
        setupRelationships(for: decodedComparisonDump.root, parent: nil)
        setupRelationships(for: decodedUpdatedDump.root, parent: nil)
        
        return recursiveCompare(
            element: decodedComparisonDump.root,
            to: decodedUpdatedDump.root,
            oldFirst: true
        ) + recursiveCompare(
            element: decodedUpdatedDump.root,
            to: decodedComparisonDump.root,
            oldFirst: false
        )
    }
}

// MARK: - Private

private extension SDKAnalyzer {
    
    static func load(from sdkDumpFilePath: String) -> SDKDump? {
        
        let fileUrl = URL(filePath: sdkDumpFilePath)
        
        return try? JSONDecoder().decode(
            SDKDump.self,
            from: Data(contentsOf: fileUrl)
        )
    }
    
    static func setupRelationships(for element: SDKDump.Element, parent: SDKDump.Element?) {
        element.children?.forEach {
            $0.parent = element
            setupRelationships(for: $0, parent: element)
        }
    }
    
    static func recursiveCompare(element lhs: SDKDump.Element, to rhs: SDKDump.Element, oldFirst: Bool) -> [Change] {
        if lhs == rhs {
            return []
        }
        
        if lhs.isSpiInternal, rhs.isSpiInternal {
            // If both elements are spi internal we can ignore them as they are not in the public interface
            return []
        }
        
        var changes = [Change]()
        
        // TODO: Add check if accessor changed (e.g. changed from get/set to get only...)
        
        if oldFirst,
           lhs.printedName != rhs.printedName ||
           lhs.spiGroupNames != rhs.spiGroupNames ||
           lhs.conformances != rhs.conformances ||
           lhs.declAttributes != rhs.declAttributes {
            // TODO: Show what exactly changed (name, spi, conformance, declAttributes, ...) as a bullet list maybe (add a `changeList` property to `Change`)
            changes += [.init(changeType: .change, parentName: lhs.parentPath, changeDescription: "`\(lhs)`\n  ➡️  `\(rhs)`")]
        }
        
        changes += lhs.children?.flatMap { lhsElement in
            if let rhsChildForName = rhs.children?.firstElementMatchingName(of: lhsElement) {
                return recursiveCompare(element: lhsElement, to: rhsChildForName, oldFirst: oldFirst)
            } else {
                if lhsElement.isSpiInternal { return [] }
                
                if oldFirst {
                    return [.init(changeType: .removal, parentName: lhsElement.parentPath, changeDescription: "`\(lhsElement)` was removed")]
                } else {
                    return [.init(changeType: .addition, parentName: lhsElement.parentPath, changeDescription: "`\(lhsElement)` was added")]
                }
            }
        } ?? []
        
        return changes
    }
}

// MARK: - Model

extension SDKAnalyzer {
    
    struct Change {
        enum ChangeType {
            case addition
            case removal
            case change
            
            var icon: String {
                switch self {
                case .addition: "❇️ "
                case .removal: "😶‍🌫️"
                case .change: "🔀"
                }
            }
        }
        
        var changeType: ChangeType
        var parentName: String
        var changeDescription: String
    }
}
