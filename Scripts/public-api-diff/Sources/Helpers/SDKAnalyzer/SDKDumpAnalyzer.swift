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
            // TODO: Show what exactly changed (name, spi, conformance, declAttributes, ...) as a bullet list maybe (add a `changeList` property to `Change`)
            changes += [.init(changeType: .change, parentName: lhs.parentPath, changeDescription: "`\(lhs)`\n  ➡️  `\(rhs)`")]
        }
        
        changes += lhs.children.flatMap { lhsElement in
            if let rhsChildForName = rhs.children.first(where: { $0.printedName == lhsElement.printedName }) {
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
        }
        
        return changes
    }
}
