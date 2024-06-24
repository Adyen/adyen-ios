//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

// MARK: - Model

struct SDKAnalyzer {
    
    let fileHandler: FileHandling
    let xcodeTools: XcodeTools
    
    init(fileHandler: FileHandling, xcodeTools: XcodeTools) {
        self.fileHandler = fileHandler
        self.xcodeTools = xcodeTools
    }
    
    public func analyze(
        old oldProjectDirectoryPath: String,
        new newProjectDirectoryPath: String
    ) throws -> [String: [SDKAnalyzer.Change]] {
        
        print("🔍 Scanning for products changes")
        
        let packageFileChanges = try analyzePackageFile(
            new: PackageFileHelper.packagePath(for: newProjectDirectoryPath),
            old: PackageFileHelper.packagePath(for: oldProjectDirectoryPath),
            fileHandler: fileHandler
        )
        
        print("🔍 Scanning for public API changes")
        
        let allTargets = try PackageFileHelper.availableTargets(
            oldProjectDirectoryPath: oldProjectDirectoryPath,
            newProjectDirectoryPath: newProjectDirectoryPath,
            fileHandler: fileHandler
        )
        
        let newDumpGenerator = SDKDumpGenerator(
            projectDirectoryPath: newProjectDirectoryPath,
            fileHandler: fileHandler,
            xcodeTools: xcodeTools
        )
        
        let oldDumpGenerator = SDKDumpGenerator(
            projectDirectoryPath: oldProjectDirectoryPath,
            fileHandler: fileHandler,
            xcodeTools: xcodeTools
        )
        
        var changesPerTarget = try analyzeSdkDump(
            for: allTargets,
            newDumpGenerator: newDumpGenerator,
            oldDumpGenerator: oldDumpGenerator
        )
        
        if !packageFileChanges.isEmpty {
            let packageTargetName = "Package.swift"
            changesPerTarget[packageTargetName] = (changesPerTarget[packageTargetName] ?? []) + packageFileChanges
        }
        
        return changesPerTarget
    }
}

// MARK: - Private

private extension SDKAnalyzer {
    
    func analyzePackageFile(
        new newPackageFilePath: String,
        old oldPackageFilePath: String,
        fileHandler: FileHandling
    ) throws -> [Change] {
        
        let oldProducts = try PackageFileHelper(
            packagePath: oldPackageFilePath,
            fileHandler: fileHandler
        ).availableProducts()
        
        let newProducts = try PackageFileHelper(
            packagePath: newPackageFilePath,
            fileHandler: fileHandler
        ).availableProducts()
        
        return analyzeProductDifferences(
            new: newProducts,
            old: oldProducts
        )
    }
    
    func analyzeProductDifferences(
        new newProducts: Set<String>,
        old oldProducts: Set<String>
    ) -> [Change] {
        
        let removedLibaries = oldProducts.subtracting(newProducts)
        var packageChanges = [Change]()
        
        packageChanges += removedLibaries.map {
            .init(
                changeType: .removal,
                parentName: "",
                changeDescription: "`.library(name: \"\($0)\", ...)` was removed"
            )
        }
        
        let addedLibraries = newProducts.subtracting(oldProducts)
        packageChanges += addedLibraries.map {
            .init(
                changeType: .addition,
                parentName: "",
                changeDescription: "`.library(name: \"\($0)\", ...)` was added"
            )
        }
        
        return packageChanges
    }
    
    func analyzeSdkDump(
        for allTargets: [String],
        newDumpGenerator: SDKDumpGenerator,
        oldDumpGenerator: SDKDumpGenerator
    ) throws -> [String: [SDKAnalyzer.Change]] {
        
        var changesPerTarget = [String: [SDKAnalyzer.Change]]() // [ModuleName: [SDKDumpAnalyzer.Change]]
        
        try allTargets.forEach { targetName in
            let diff = try SDKAnalyzer.diffSdkDump(
                newDump: newDumpGenerator.generate(for: targetName),
                oldDump: oldDumpGenerator.generate(for: targetName)
            )
            
            if !diff.isEmpty { changesPerTarget[targetName] = diff }
        }
        
        return changesPerTarget
    }
    
    static func diffSdkDump(
        newDump: SDKDump?,
        oldDump: SDKDump?
    ) throws -> [Change] {
        
        guard newDump != oldDump else { return [] }
        
        guard let newDump else {
            return [.init(changeType: .removal, parentName: "", changeDescription: "Target was removed")]
        }
        
        guard let oldDump else {
            return [.init(changeType: .addition, parentName: "", changeDescription: "Target was added")]
        }
        
        return recursiveCompare(
            element: oldDump.root,
            to: newDump.root,
            oldFirst: true
        ) + recursiveCompare(
            element: newDump.root,
            to: oldDump.root,
            oldFirst: false
        )
    }
    
    static func recursiveCompare(element lhs: SDKDump.Element, to rhs: SDKDump.Element, oldFirst: Bool) -> [Change] {
        if lhs == rhs { return [] }
        
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
            if let rhsChildForName = rhs.children?.first(where: { $0.printedName == lhsElement.printedName }) {
                return recursiveCompare(element: lhsElement, to: rhsChildForName, oldFirst: oldFirst)
            } else {
                // Type changes we handle as a change, not an addition/removal (they are in the children array tho)
                if lhsElement.isTypeInformation { return [] }
                
                // An spi-internal element was added/removed which we do not count as a public change
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
