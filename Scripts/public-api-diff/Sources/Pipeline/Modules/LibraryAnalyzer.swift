//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct LibraryAnalyzer: LibraryAnalyzing {
    
    let fileHandler: FileHandling
    let xcodeTools: XcodeTools
    
    init(
        fileHandler: FileHandling = FileManager.default,
        xcodeTools: XcodeTools = XcodeTools()
    ) {
        self.fileHandler = fileHandler
        self.xcodeTools = xcodeTools
    }
    
    func analyze(oldProjectUrl: URL, newProjectUrl: URL) throws -> [Change] {
        
        let oldProjectPath = oldProjectUrl.path()
        let newProjectPath = newProjectUrl.path()
        
        let oldPackagePath = PackageFileHelper.packagePath(for: oldProjectPath)
        let newPackagePath = PackageFileHelper.packagePath(for: newProjectPath)
        
        if fileHandler.fileExists(atPath: oldPackagePath), fileHandler.fileExists(atPath: newPackagePath) {
            let oldPackageHelper = PackageFileHelper(fileHandler: fileHandler, xcodeTools: xcodeTools)
            let newPackageHelper = PackageFileHelper(fileHandler: fileHandler, xcodeTools: xcodeTools)
            
            return try analyze(
                old: oldPackageHelper.availableProducts(at: oldProjectPath),
                new: newPackageHelper.availableProducts(at: newProjectPath)
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
