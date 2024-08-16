//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A change indicating an `addition` or `removal` of an element
///
/// This intermediate structure helps gathering a list of additions and removals
/// that are later consolidated to a ``Change``
struct IndependentChange: Equatable {
    enum ChangeType: Equatable {
        case addition(_ description: String)
        case removal(_ description: String)

        var description: String {
            switch self {
            case let .addition(description): description
            case let .removal(description): description
            }
        }
    }

    let changeType: ChangeType
    let element: SDKDump.Element

    let oldFirst: Bool
    var parentName: String { element.parentPath }
}
