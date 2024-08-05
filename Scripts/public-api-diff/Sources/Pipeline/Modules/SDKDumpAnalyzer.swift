//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

private struct IndependentChange {
    
    enum ChangeType {
        case addition(_ description: String)
        case removal(_ description: String)
    }
    
    let changeType: ChangeType
    var parentName: String { element.parentPath }
    let element: SDKDump.Element
    let oldFirst: Bool
}

struct SDKDumpAnalyzer: SDKDumpAnalyzing {
    
    func analyze(
        old: SDKDump,
        new: SDKDump
    ) -> [Change] {
        
        let changes = Self.recursiveCompare(
            element: old.root,
            to: new.root,
            oldFirst: true
        ) + Self.recursiveCompare(
            element: new.root,
            to: old.root,
            oldFirst: false
        )
        
        // Matching removals/additions to changes when applicable
        return ChangeConsolidator().consolidate(changes)
    }
    
    private static func recursiveCompare(element lhs: SDKDump.Element, to rhs: SDKDump.Element, oldFirst: Bool) -> [IndependentChange] {
        if lhs == rhs { return [] }
        
        // If both elements are spi internal we can ignore them as they are not in the public interface
        if lhs.isSpiInternal, rhs.isSpiInternal { return [] }
        
        // If both elements are internal we can ignore them as they are not in the public interface
        if lhs.isInternal, rhs.isInternal { return [] }
        
        var changes = [IndependentChange]()
        
        if oldFirst, lhs.description != rhs.description {
            changes += [
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
        }
        
        changes += lhs.children.flatMap { lhsElement -> [IndependentChange] in

            // Trying to find a matching element
            if let rhsChildForName = rhs.children.first(where: { $0.isComparable(to: lhsElement) }) {
                // We found a matching element so we check if the children changed
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

// MARK: - Consolidation

/// A helper to consolidate a `removal` and `addition` to `change`
private struct ChangeConsolidator {
    
    /// Tries to match a `removal` and `addition` to a `change`
    ///
    /// - Parameters:
    ///   - changes: The independent changes (`addition`/`removal`) to try to match
    ///
    /// e.g. if we have a `removal` `init(foo: Int, bar: Int) -> Void` and an `addition` `init(foo: Int, bar: Int, baz: String) -> Void`
    /// It will get consolidated to a `change` based on the `name`, `parent` & `declKind`
    /// The changeType will be also respected so `removals` only get matched with `additions` and vice versa.
    ///
    /// This can lead to false positive matches in cases where one `removal` could potentially be matched to multiple `additions` or vice versa.
    /// e.g. a second `addition` `init(unrelated: String) -> SomeType` might be matched as a change of `init(foo: Int, bar: Int) -> Void`
    /// as they share the same comparison features but might not be an actual change but a genuine addition.
    /// This is acceptable for now but might be improved in the future (e.g. calculating a matching-percentage)
    func consolidate(_ changes: [IndependentChange]) -> [Change] {
        
        var independentChanges = changes
        var consolidatedChanges = [Change]()
        
        while !independentChanges.isEmpty {
            let change = independentChanges.removeFirst()
            
            // Trying to find 2 independent changes that could actually have been a change instead of an addition/removal
            guard let nameAndTypeMatchIndex = independentChanges.firstIndex(where: { $0.isConsolidatable(with: change) }) else {
                consolidatedChanges.append(
                    .init(
                        changeType: change.changeType.toConsolidatedChangeType,
                        parentName: change.parentName,
                        listOfChanges: nil
                    )
                )
                continue
            }
        
            let match = independentChanges.remove(at: nameAndTypeMatchIndex)
            let oldDescription = change.oldFirst ? change.element.description : match.element.description
            let newDescription = change.oldFirst ? match.element.description : change.element.description
            let listOfChanges = listOfChanges(between: change, and: match)
            
            consolidatedChanges.append(
                .init(
                    changeType: .change(
                        oldDescription: oldDescription,
                        newDescription: newDescription
                    ),
                    parentName: match.parentName,
                    listOfChanges: listOfChanges
                )
            )
        }
        
        return consolidatedChanges
    }
    
    /// Compiles a list of changes between 2 independent changes
    func listOfChanges(between lhs: IndependentChange, and rhs: IndependentChange) -> [String] {
        if rhs.oldFirst {
            lhs.element.difference(to: rhs.element)
        } else {
            rhs.element.difference(to: lhs.element)
        }
    }
}

private extension IndependentChange {
    
    /// Helper method to construct an IndependentChange from the changeType & element
    static func from(changeType: ChangeType, element: SDKDump.Element, oldFirst: Bool) -> Self {
        .init(
            changeType: changeType,
            element: element,
            oldFirst: oldFirst
        )
    }
    
    /// Checks whether or not 2 changes can be diffed based on their elements `name`, `declKind` and `parentPath`.
    /// It also checks if the `changeType` is different to not compare 2 additions/removals with eachother.
    ///
    /// If the `name`, `declKind`, `parentPath` of the element is the same we can assume that it's the same element but altered.
    /// We're using the `name` and not the `printedName` is intended to be used to figure out if an addition & removal is actually a change.
    /// `name` is more generic than `printedName` as it (for functions) does not take the arguments into account.
    ///
    /// e.g. if we have a function `init(foo: Int, bar: Int) -> Void` the `name` would be `init` and `printedName` would be `init(foo:bar:)`.
    /// It could cause a false positive with other functions named `init` (e.g. convenience inits) when trying to find matching elements during the finding phase.
    /// Here we already found the matching elements and thus are looking for combining a removal/addition to a change and thus we can loosen the filter to use the `name`.
    /// It could potentially still lead to false positives when having multiple functions with changes and the same name and parent but this is acceptable in this phase.
    func isConsolidatable(with otherChange: IndependentChange) -> Bool {
        element.name == otherChange.element.name &&
        element.declKind == otherChange.element.declKind &&
        element.parentPath == otherChange.element.parentPath &&
        changeType.isAddition != otherChange.changeType.isAddition // We only want to match independent changes that are hava a different changeType
    }
}

private extension IndependentChange.ChangeType {
    
    /// Whether or not the type is an `.addition`
    var isAddition: Bool {
        switch self {
        case .addition: true
        case .removal: false
        }
    }
    
    /// Whether or not the type is an `.removal`
    var isRemoval: Bool {
        switch self {
        case .addition: false
        case .removal: true
        }
    }
    
    /// Converts a `IndependentChange.ChangeType` to a `Change.ChangeType`
    var toConsolidatedChangeType: Change.ChangeType {
        switch self {
        case .addition(let description):
            return .addition(description: description)
        case .removal(let description):
            return .removal(description: description)
        }
    }
}
