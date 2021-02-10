//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal struct ComponentsItem: Hashable {

    internal var title: String
    
    internal var selectionHandler: (() -> Void)?
    
    internal init(title: String, selectionHandler: (() -> Void)? = nil) {
        self.title = title
        self.selectionHandler = selectionHandler
    }

    internal static func == (lhs: ComponentsItem, rhs: ComponentsItem) -> Bool {
        lhs.title == rhs.title
    }

    internal func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
}
