//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

enum SDKDumpAnalyzer {
    
    static func analyzeSdkDump(
        newDump: SDKDump?,
        oldDump: SDKDump?
    ) -> [SDKAnalyzer.Change] {
        
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
    
    private static func recursiveCompare(element lhs: SDKDump.Element, to rhs: SDKDump.Element, oldFirst: Bool) -> [SDKAnalyzer.Change] {
        if lhs == rhs { return [] }
        
        if lhs.isSpiInternal, rhs.isSpiInternal {
            // If both elements are spi internal we can ignore them as they are not in the public interface
            return []
        }
        
        var changes = [SDKAnalyzer.Change]()
        
        if oldFirst, lhs.definition != rhs.definition {
            changes += [
                .init(changeType: .removal, parentName: lhs.parentPath, changeDescription: "`\(lhs)` was removed"),
                .init(changeType: .addition, parentName: rhs.parentPath, changeDescription: "`\(rhs)` was added")
            ]
        }
        
        changes += lhs.children.flatMap { lhsElement in

            // We're comparing the definition which means that additions to or removals from a definition 
            // (e.g. adding protocol conformance or a new/changed parameter name) will cause an element
            // to be marked as added/removed.
            // This simplifies the script and also makes it more accurate
            // but has the downside of running into the chance of not grouping the changed element together
            
            if let rhsChildForName = rhs.children.first(where: { $0.definition == lhsElement.definition }) {
                return recursiveCompare(element: lhsElement, to: rhsChildForName, oldFirst: oldFirst)
            }
            
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
        
        return changes
    }
}
