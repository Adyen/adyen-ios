//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 26/06/2024.
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
