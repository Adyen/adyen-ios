//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

// MARK: - Model

struct SDKAnalyzer {
    
    private let fileHandler: FileHandling
    private let xcodeTools: XcodeTools
    
    init(fileHandler: FileHandling, xcodeTools: XcodeTools) {
        self.fileHandler = fileHandler
        self.xcodeTools = xcodeTools
    }
    
    public func analyze(
        old oldProjectDirectoryPath: String,
        new newProjectDirectoryPath: String
    ) throws -> [String: [SDKAnalyzer.Change]] {
        
        print("🔍 Scanning for products changes")
        
        let packageFileChanges = try Self.analyzePackageFile(
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
        
        var changesPerTarget = try Self.analyzeSdkDumps(
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
    
    static func analyzePackageFile(
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
        
        return PackageAnalyzer.analyzeProductDifferences(
            new: newProducts,
            old: oldProducts
        )
    }
    
    private static func analyzeSdkDumps(
        for allTargets: [String],
        newDumpGenerator: SDKDumpGenerator,
        oldDumpGenerator: SDKDumpGenerator
    ) throws -> [String: [SDKAnalyzer.Change]] {
        
        var changesPerTarget = [String: [SDKAnalyzer.Change]]() // [ModuleName: [SDKDumpAnalyzer.Change]]
        
        allTargets.forEach { targetName in
            
            var newDump: SDKDump? = nil
            var oldDump: SDKDump? = nil
            
            do {
                newDump = try newDumpGenerator.generate(for: targetName)
                oldDump = try oldDumpGenerator.generate(for: targetName)
            } catch {
                print(error)
            }
            
            let diff = SDKDumpAnalyzer.analyzeSdkDump(
                newDump: newDump,
                oldDump: oldDump
            )
            
            if !diff.isEmpty { changesPerTarget[targetName] = diff }
        }
        
        return changesPerTarget
    }
}
