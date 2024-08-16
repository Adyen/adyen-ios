//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct SDKDumpAnalyzer: SDKDumpAnalyzing {
    
    let changeConsolidator: ChangeConsolidating
    
    init(
        changeConsolidator: ChangeConsolidating = ChangeConsolidator()
    ) {
        self.changeConsolidator = changeConsolidator
    }
    
    func analyze(
        old: SDKDump,
        new: SDKDump
    ) -> [Change] {
        
        let individualChanges = Self.recursiveCompare(
            element: old.root,
            to: new.root,
            oldFirst: true
        ) + Self.recursiveCompare(
            element: new.root,
            to: old.root,
            oldFirst: false
        )
        
        // Matching removals/additions to changes when applicable
        return changeConsolidator.consolidate(individualChanges)
    }
    
    private static func recursiveCompare(
        element lhs: SDKDump.Element,
        to rhs: SDKDump.Element,
        oldFirst: Bool
    ) -> [IndependentChange] {
        
        if lhs == rhs { return [] }
        
        // If both elements are spi internal we can ignore them as they are not in the public interface
        if lhs.isSpiInternal, rhs.isSpiInternal { return [] }
        
        // If both elements are internal we can ignore them as they are not in the public interface
        if lhs.isInternal, rhs.isInternal { return [] }
        
        var changes = [IndependentChange]()
        
        if oldFirst, lhs.description != rhs.description {
            changes += independentChanges(from: lhs, and: rhs, oldFirst: oldFirst)
        }
        
        changes += lhs.children.flatMap { lhsElement in

            // Trying to find a matching element
            
            // First checking if we found an exact match based on the description
            // as we don't want to match a non-change with a change
            if let exactMatch = rhs.children.first(where: { $0.description == lhsElement.description }) {
                // We found an exact match so we check if the children changed
                return recursiveCompare(element: lhsElement, to: exactMatch, oldFirst: oldFirst)
            }

            // ... then losening the criteria to find a comparable element
            if let rhsChildForName = rhs.children.first(where: { $0.isComparable(to: lhsElement) }) {
                // We found a comparable element so we check if the children changed
                return recursiveCompare(element: lhsElement, to: rhsChildForName, oldFirst: oldFirst)
            }
    
            // No matching element was found so either it was removed or added
            
            // Type changes get caught during comparing the description and would only add noise to the output
            if lhsElement.isTypeInformation { return [] }
            
            // An (spi-)internal element was added/removed which we do not count as a public change
            if lhsElement.isSpiInternal || lhsElement.isInternal { return [] }
            
            let changeType: IndependentChange.ChangeType = oldFirst ?
                .removal(lhsElement.description) :
                .addition(lhsElement.description)

            return [
                .from(
                    changeType: changeType,
                    element: lhsElement,
                    oldFirst: oldFirst
                )
            ]
        }
        
        return changes
    }
    
    private static func independentChanges(
        from lhs: SDKDump.Element,
        and rhs: SDKDump.Element,
        oldFirst: Bool
    ) -> [IndependentChange] {
        
        var changes: [IndependentChange] = [
            .from(
                changeType: .removal(lhs.description),
                element: lhs,
                oldFirst: oldFirst
            )
        ]
        
        if !rhs.isSpiInternal {
            // We only report additions if they are not @_spi
            changes += [
                .from(
                    changeType: .addition(rhs.description),
                    element: rhs,
                    oldFirst: oldFirst
                )
            ]
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
