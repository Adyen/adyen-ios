//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A helper to consolidate a `removal` and `addition` to `change`
protocol ChangeConsolidating {
    
    /// Tries to match a `removal` and `addition` to a `change`
    ///
    /// - Parameters:
    ///   - changes: The independent changes (`addition`/`removal`) to try to match
    func consolidate(_ changes: [IndependentChange]) -> [Change]
}

struct ChangeConsolidator: ChangeConsolidating {

    /// Tries to match a `removal` and `addition` to a `change`
    ///
    /// - Parameters:
    ///   - changes: The independent changes (`addition`/`removal`) to try to match
    ///
    /// e.g. if we have a `removal` `init(foo: Int, bar: Int)` and an `addition` `init(foo: Int, bar: Int, baz: String)`
    /// It will get consolidated to a `change` based on the `name`, `parent` & `declKind`
    /// The changeType will be also respected so `removals` only get matched with `additions` and vice versa.
    ///
    /// This can lead to false positive matches in cases where one `removal` could potentially be matched to multiple `additions` or vice versa.
    /// e.g. a second `addition` `init(unrelated: String)` might be matched as a change of `init(foo: Int, bar: Int)`
    /// as they share the same comparison features but might not be an actual change but a genuine addition.
    /// This is acceptable for now but might be improved in the future (e.g. calculating a matching-percentage)
    func consolidate(_ changes: [IndependentChange]) -> [Change] {

        var independentChanges = changes
        var consolidatedChanges = [Change]()

        while !independentChanges.isEmpty {
            let change = independentChanges.removeFirst()

            // Trying to find 2 independent changes that could actually have been a change instead of an addition/removal
            guard let nameAndTypeMatchIndex = independentChanges.firstIndex(where: { $0.isConsolidatable(with: change) }) else {
                consolidatedChanges.append(change.toConsolidatedChange)
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
        if lhs.oldFirst {
            lhs.element.differences(to: rhs.element)
        } else {
            rhs.element.differences(to: lhs.element)
        }
    }
}

extension IndependentChange {

    var toConsolidatedChange: Change {
        let changeType: Change.ChangeType = {
            switch self.changeType {
            case let .addition(description):
                .addition(description: description)
            case let .removal(description):
                .removal(description: description)
            }
        }()

        return .init(
            changeType: changeType,
            parentName: parentName,
            listOfChanges: []
        )
    }

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
            changeType.name != otherChange.changeType.name // We only want to match independent changes that are hava a different changeType
    }
}

private extension IndependentChange.ChangeType {

    /// The name of the type (without associated value) as String
    var name: String {
        switch self {
        case .addition: "addition"
        case .removal: "removal"
        }
    }
}
