//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct LibraryAnalyzer: LibraryAnalyzing {
    
    let fileHandler: any FileHandling
    
    init(fileHandler: any FileHandling = FileManager.default) {
        self.fileHandler = fileHandler
    }
    
    func analyze(oldProjectUrl: URL, newProjectUrl: URL) throws -> [Change] {
        
        let oldPackagePath = PackageFileHelper.packagePath(for: oldProjectUrl.path())
        let newPackagePath = PackageFileHelper.packagePath(for: newProjectUrl.path())
        
        if fileHandler.fileExists(atPath: oldPackagePath), fileHandler.fileExists(atPath: newPackagePath) {
            let oldPackageHelper = PackageFileHelper(packagePath: oldPackagePath, fileHandler: fileHandler)
            let newPackageHelper = PackageFileHelper(packagePath: newPackagePath, fileHandler: fileHandler)
            
            return try analyze(
                old: oldPackageHelper.availableProducts(),
                new: newPackageHelper.availableProducts()
            )
        } else {
            return []
        }
    }
    
    private func analyze(
        old oldLibraries: Set<String>,
        new newLibraries: Set<String>
    ) throws -> [Change] {
        
        let removedLibaries = oldLibraries.subtracting(newLibraries)
        var packageChanges = [Change]()
        
        packageChanges += removedLibaries.map {
            .init(
                changeType: .removal,
                parentName: "",
                changeDescription: "`.library(name: \"\($0)\", ...)` was removed"
            )
        }
        
        let addedLibraries = newLibraries.subtracting(oldLibraries)
        packageChanges += addedLibraries.map {
            .init(
                changeType: .addition,
                parentName: "",
                changeDescription: "`.library(name: \"\($0)\", ...)` was added"
            )
        }
        
        return packageChanges
    }
}
