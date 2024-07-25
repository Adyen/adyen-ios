//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

private struct TmpChange {
    let change: Change
    let element: SDKDump.Element
    let oldFirst: Bool
}

extension [TmpChange] {
    var consolidated: [Change] {
        var tmpChanges = self
        var consolidatedChanges = [Change]()
        
        while !tmpChanges.isEmpty {
            let firstChange = tmpChanges.removeFirst()
            
            if let nameAndTypeMatchIndex = tmpChanges.firstIndex(where: { $0.element.isComparable(to: firstChange.element) }) {
                let match = tmpChanges[nameAndTypeMatchIndex]
                
                let changeDescription = {
                    if match.oldFirst {
                        "`\(match.element.description)`\n  ➡️ `\(firstChange.element.description)`"
                    } else {
                        "`\(firstChange.element.description)`\n  ➡️ `\(match.element.description)`"
                    }
                }()
                
                let changeSummary = {
                    if match.oldFirst {
                        firstChange.element.compare(to: match.element)
                    } else {
                        match.element.compare(to: firstChange.element)
                    }
                }()
                
                consolidatedChanges.append(
                    .init(
                        changeType: .change,
                        parentName: match.element.parentPath,
                        changeDescription: changeDescription,
                        listOfChanges: changeSummary
                    )
                )
                tmpChanges.remove(at: nameAndTypeMatchIndex)
            } else {
                consolidatedChanges.append(firstChange.change)
            }
        }
        
        return consolidatedChanges
    }
}

extension SDKDump.Element {
    
    func isComparable(to otherElement: SDKDump.Element) -> Bool {
        name == otherElement.name && declKind == otherElement.declKind && parentPath == otherElement.parentPath
    }
    
    func compare(to otherElement: SDKDump.Element) -> [String]? {
        guard let declKind = self.declKind, let otherDeclKind = otherElement.declKind, declKind == otherDeclKind else { return nil }
        
        // TODO: Move every comparison to a function (can be used on multiple declKinds)
        
        switch declKind {
        case .import, .accessor, .subscriptDeclaration, .macro:
            return []
        case .class:
            // Comparing: conformances, final, spi
            var diff = [String]()
            
            if self.isFinal != otherElement.isFinal {
                if isFinal {
                    diff.append("`final` keyword was added")
                } else {
                    diff.append("`final` keyword was removed")
                }
            }
            
            if self.isSpiInternal != otherElement.isSpiInternal {
                if isSpiInternal {
                    diff.append("`final` was added")
                } else {
                    diff.append("`final` was removed")
                }
            }
            
            let ownSpiGroupNames = Set(spiGroupNames ?? [])
            let otherSpiGroupNames = Set(otherElement.spiGroupNames ?? [])
            
            ownSpiGroupNames.symmetricDifference(otherSpiGroupNames).forEach {
                if ownSpiGroupNames.contains($0) {
                    diff.append("`@_spi(\($0))` was added")
                } else {
                    diff.append("`@_spi(\($0))` was removed")
                }
            }
            
            let ownConformances = Set(conformances ?? [])
            let otherConformances = Set(otherElement.conformances ?? [])
            
            ownConformances.symmetricDifference(otherConformances).forEach {
                if ownConformances.contains($0) {
                    diff.append("\($0.printedName) conformance was added")
                } else {
                    diff.append("\($0.printedName) conformance was removed")
                }
            }
            
            return diff
        case .struct:
            // Comparing: conformances, spi
            var diff = [String]()
            
            if self.isSpiInternal != otherElement.isSpiInternal {
                if isSpiInternal {
                    diff.append("`final` was added")
                } else {
                    diff.append("`final` was removed")
                }
            }
            
            let ownSpiGroupNames = Set(spiGroupNames ?? [])
            let otherSpiGroupNames = Set(otherElement.spiGroupNames ?? [])
            
            ownSpiGroupNames.symmetricDifference(otherSpiGroupNames).forEach {
                if ownSpiGroupNames.contains($0) {
                    diff.append("`@_spi(\($0))` was added")
                } else {
                    diff.append("`@_spi(\($0))` was removed")
                }
            }
            
            let ownConformances = Set(conformances ?? [])
            let otherConformances = Set(otherElement.conformances ?? [])
            
            ownConformances.symmetricDifference(otherConformances).forEach {
                if ownConformances.contains($0) {
                    diff.append("\($0.printedName) conformance was added")
                } else {
                    diff.append("\($0.printedName) conformance was removed")
                }
            }
            
            return diff
        case .enum:
            // TODO: Compare conformances, spi
            return []
        case .case:
            return []
        case .var:
            // TODO: Compare accessors, spi
            return []
        case .func:
            // TODO: Compare return, types, properties, async?!
            return []
        case .protocol:
            // TODO: Compare conformances
            return []
        case .constructor:
            // TODO: Same as function
            return []
        case .typeAlias:
            // TODO: Compare type
            return ["Renamed"]
        case .associatedType:
            return []
        }
    }
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
