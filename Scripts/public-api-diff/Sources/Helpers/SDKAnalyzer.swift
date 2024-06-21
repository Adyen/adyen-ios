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
            newDumpGenerator: .init(projectDirectoryPath: newProjectDirectoryPath),
            oldDumpGenerator: .init(projectDirectoryPath: oldProjectDirectoryPath)
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
        
        let oldProducts = try PackageFileHelper(packagePath: comparisonPackageFilePath).availableProducts()
        let newProducts = try PackageFileHelper(packagePath: updatedPackageFilePath).availableProducts()
        
        let removedLibaries = oldProducts.subtracting(newProducts)
        libraryChanges += removedLibaries.map {
            .init(
                changeType: .removal,
                parentName: "",
                changeDescription: "`.library(name: \"\($0)\", ...)` was removed"
            )
        }
        
        let addedLibraries = newProducts.subtracting(oldProducts)
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
        newDumpGenerator: SDKDumpGenerator,
        oldDumpGenerator: SDKDumpGenerator
    ) throws -> [String: [SDKAnalyzer.Change]] {
        
        var changesPerTarget = [String: [SDKAnalyzer.Change]]() // [ModuleName: [SDKDumpAnalyzer.Change]]
        
        try allTargets.forEach { targetName in
            let newDumpFilePath = newDumpGenerator.generate(for: targetName)
            let oldDumpFilePath = oldDumpGenerator.generate(for: targetName)
            
            let diff = try SDKAnalyzer.diffSdkDump(
                new: newDumpFilePath,
                old: oldDumpFilePath
            )
            
            if !diff.isEmpty { changesPerTarget[targetName] = diff }
        }
        
        return changesPerTarget
    }
    
    private static func diffSdkDump(
        new newDumpFilePath: String,
        old oldDumpFilePath: String
    ) throws -> [Change] {
        
        let decodedNewDump = load(from: newDumpFilePath)
        let decodedOldDump = load(from: oldDumpFilePath)
        
        guard decodedNewDump != decodedOldDump else {
            return []
        }
        
        guard let decodedNewDump else {
            return [.init(changeType: .removal, parentName: "", changeDescription: "Target was removed")]
        }
        
        guard let decodedOldDump else {
            return [.init(changeType: .addition, parentName: "", changeDescription: "Target was added")]
        }
        
        setupRelationships(for: decodedNewDump.root, parent: nil)
        setupRelationships(for: decodedOldDump.root, parent: nil)
        
        return recursiveCompare(
            element: decodedOldDump.root,
            to: decodedNewDump.root,
            oldFirst: true
        ) + recursiveCompare(
            element: decodedNewDump.root,
            to: decodedOldDump.root,
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
        
        if oldFirst, lhs.definition != rhs.definition {
            // TODO: Show what exactly changed (name, spi, conformance, declAttributes, ...) as a bullet list maybe (add a `changeList` property to `Change`)
            changes += [.init(changeType: .change, parentName: lhs.parentPath, changeDescription: "`\(lhs)`\n  ➡️  `\(rhs)`")]
        }
        
        changes += lhs.children?.flatMap { lhsElement in
            if let rhsChildForName = rhs.children?.first(where: { $0.name == lhsElement.name }) {
                return recursiveCompare(element: lhsElement, to: rhsChildForName, oldFirst: oldFirst)
            } else {
                // Type changes we handle as a change, not an addition/removal (they are in the children array tho)
                if lhsElement.kind == "TypeNominal" { return [] }
                
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

extension [String: [SDKAnalyzer.Change]] {
    
    var totalChangeCount: Int {
        var totalChangeCount = 0
        keys.forEach { targetName in
            totalChangeCount += self[targetName]?.count ?? 0
        }
        return totalChangeCount
    }
}
