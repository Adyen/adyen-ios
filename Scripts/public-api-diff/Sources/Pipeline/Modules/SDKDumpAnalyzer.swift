//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct SDKDumpAnalyzer: SDKDumpAnalyzing {
    
    func analyze(
        old: SDKDump,
        new: SDKDump
    ) -> [Change] {
        
        Self.recursiveCompare(
            element: old.root,
            to: new.root,
            oldFirst: true
        ) + Self.recursiveCompare(
            element: new.root,
            to: old.root,
            oldFirst: false
        )
    }
    
    private static func recursiveCompare(element lhs: SDKDump.Element, to rhs: SDKDump.Element, oldFirst: Bool) -> [Change] {
        if lhs == rhs { return [] }
        
        if lhs.isSpiInternal, rhs.isSpiInternal {
            // If both elements are spi internal we can ignore them as they are not in the public interface
            return []
        }
        
        if lhs.isInternal, rhs.isInternal {
            // If both elements are spi internal we can ignore them as they are not in the public interface
            return []
        }
        
        var changes = [Change]()
        
        if oldFirst, lhs.description != rhs.description {
            changes += [.init(changeType: .removal(description: "`\(lhs)` was removed"), parentName: lhs.parentPath)]
            
            if !rhs.isSpiInternal {
                changes += [.init(changeType: .addition(description: "`\(rhs)` was added"), parentName: rhs.parentPath)]
            }
        }
        
        changes += lhs.children.flatMap { lhsElement in

            // We're comparing the definition which means that additions to or removals from a definition
            // (e.g. adding protocol conformance or a new/changed parameter name) will cause an element
            // to be marked as added/removed.
            // This simplifies the script and also makes it more accurate
            // but has the downside of running into the chance of not grouping the changed element together
            
            // First checking if we found an exact match based on the description
            // as we don't want to match a non-change with a change
            if let exactMatch = rhs.children.first(where: { $0.description == lhsElement.description }) {
                // We found an exact match so we check if the children changed
                return recursiveCompare(element: lhsElement, to: exactMatch, oldFirst: oldFirst)
            }

            // ... then losening the criteria to find a comparable element
            if let rhsChildForName = rhs.children.first(where: { $0.isComparable(to: lhsElement) }) {
                return recursiveCompare(element: lhsElement, to: rhsChildForName, oldFirst: oldFirst)
            }
            
            // Type changes we handle as a change, not an addition/removal (they are in the children array tho)
            if lhsElement.isTypeInformation { return [] }
            
            // An spi-internal element was added/removed which we do not count as a public change
            if lhsElement.isSpiInternal { return [] }
            
            if oldFirst {
                return [.init(changeType: .removal(description: "`\(lhsElement)` was removed"), parentName: lhsElement.parentPath)]
            } else {
                return [.init(changeType: .addition(description: "`\(lhsElement)` was added"), parentName: lhsElement.parentPath)]
            }
        }
        
        return changes
    }
}

private extension SDKDump.Element {
    
    /// Checks whether or not 2 elements can be compared based on their `printedName`, `declKind` and `parentPath`
    ///
    /// If the `printedName`, `declKind` + `parentPath` is the same we can assume that it's the same element but altered
    /// We're using the `printedName` and not the `name` as for example there could be multiple functions with the same name but different parameters.
    /// In this specific case we want to find an exact match of the signature.
    ///
    /// e.g. if we have a function `init(foo: Int, bar: Int) -> Void` the `name` would be `init` and `printedName` would be `init(foo:bar:)`.
    /// If we used the `name` it could cause a false positive with other functions named `init` (e.g. convenience inits) when trying to find matching elements during this finding phase.
    /// In a later consolidation phase removals/additions are compared again based on their `name` to combine them to a `change`
    func isComparable(to otherElement: SDKDump.Element) -> Bool {
        printedName == otherElement.printedName && 
        declKind == otherElement.declKind &&
        parentPath == otherElement.parentPath
    }
}
