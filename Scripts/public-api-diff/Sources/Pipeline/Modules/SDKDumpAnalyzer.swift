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
        
        let changes = Self.recursiveCompare(
            element: old.root,
            to: new.root,
            oldFirst: true
        ) + Self.recursiveCompare(
            element: new.root,
            to: old.root,
            oldFirst: false
        )
        
        return changes.consolidated
    }
    
    private static func recursiveCompare(element lhs: SDKDump.Element, to rhs: SDKDump.Element, oldFirst: Bool) -> [TmpChange] {
        if lhs == rhs { return [] }
        
        if lhs.isSpiInternal, rhs.isSpiInternal {
            // If both elements are spi internal we can ignore them as they are not in the public interface
            return []
        }
        
        if lhs.isInternal, rhs.isInternal {
            // If both elements are spi internal we can ignore them as they are not in the public interface
            return []
        }
        
        var changes = [TmpChange]()
        
        if oldFirst, lhs.description != rhs.description {
            changes += [
                .init(
                    change: .init(changeType: .removal, parentName: lhs.parentPath, changeDescription: "`\(lhs)` was removed"),
                    element: lhs,
                    oldFirst: oldFirst
                ),
                .init(
                    change: .init(changeType: .addition, parentName: rhs.parentPath, changeDescription: "`\(rhs)` was added"),
                    element: rhs,
                    oldFirst: oldFirst
                )
            ]
        }
        
        changes += lhs.children.flatMap { lhsElement in

            // We're comparing the description which means that additions to or removals from a definition
            // (e.g. adding protocol conformance or a new/changed parameter name) will cause an element
            // to be marked as added/removed.
            // This simplifies the script and also makes it more accurate
            // but has the downside of running into the chance of not grouping the changed element together
            
            // TODO: Maybe already use the comparison of type/name/parent here to not having to need the TmpChange but just do it immediately here
            if let rhsChildForName = rhs.children.first(where: { $0.description == lhsElement.description }) {
                return recursiveCompare(element: lhsElement, to: rhsChildForName, oldFirst: oldFirst)
            }
            
            // Type changes we handle as a change, not an addition/removal (they are in the children array tho)
            if lhsElement.isTypeInformation { return [] }
            
            // An spi-internal element was added/removed which we do not count as a public change
            if lhsElement.isSpiInternal { return [] }
            
            if oldFirst {
                return [
                    .init(
                        change: .init(changeType: .removal, parentName: lhsElement.parentPath, changeDescription: "`\(lhsElement)` was removed"),
                        element: lhsElement,
                        oldFirst: oldFirst
                    )
                ]
            } else {
                return [
                    .init(
                        change: .init(changeType: .addition, parentName: lhsElement.parentPath, changeDescription: "`\(lhsElement)` was added"),
                        element: lhsElement,
                        oldFirst: oldFirst
                    )
                ]
            }
        }
        
        return changes
    }
}

// MARK: - Consolidation

// TODO: Rename/Refactor
private struct TmpChange {
    let change: Change
    let element: SDKDump.Element
    let oldFirst: Bool
}

private extension [TmpChange] {
    
    var consolidated: [Change] {
        
        var tmpChanges = self
        var consolidatedChanges = [Change]()
        
        while !tmpChanges.isEmpty {
            let firstChange = tmpChanges.removeFirst()
            
            if let nameAndTypeMatchIndex = tmpChanges.firstIndex(where: { $0.element.isComparable(to: firstChange.element) }) {
                let match = tmpChanges[nameAndTypeMatchIndex]
                
                let changeDescription = changeDescription(
                    for: firstChange,
                    and: match
                )
                
                let listOfChanges = listOfChanges(
                    between: firstChange,
                    and: match
                )
                
                consolidatedChanges.append(
                    .init(
                        changeType: .change,
                        parentName: match.element.parentPath,
                        changeDescription: changeDescription,
                        listOfChanges: listOfChanges
                    )
                )
                tmpChanges.remove(at: nameAndTypeMatchIndex)
            } else {
                consolidatedChanges.append(firstChange.change)
            }
        }
        
        return consolidatedChanges
    }
    
    func changeDescription(for lhs: TmpChange, and rhs: TmpChange) -> String {
        if rhs.oldFirst {
            "`\(rhs.element.description)`\n  ➡️ `\(lhs.element.description)`"
        } else {
            "`\(lhs.element.description)`\n  ➡️ `\(rhs.element.description)`"
        }
    }
    
    func listOfChanges(between lhs: TmpChange, and rhs: TmpChange) -> [String] {
        if rhs.oldFirst {
            lhs.element.difference(to: rhs.element)
        } else {
            rhs.element.difference(to: lhs.element)
        }
    }
}
