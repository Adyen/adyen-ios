//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

enum PackageAnalyzer {
    
    static func analyzeProductDifferences(
        new newProducts: Set<String>,
        old oldProducts: Set<String>
    ) -> [SDKAnalyzer.Change] {
        
        let removedLibaries = oldProducts.subtracting(newProducts)
        var packageChanges = [SDKAnalyzer.Change]()
        
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
}
