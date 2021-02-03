//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal struct ComponentItem: Hashable {

    internal var title: String
    
    internal var selectionHandler: (() -> Void)?
    
    internal init(title: String, present: (() -> Void)? = nil) {
        self.title = title
        selectionHandler = present
    }

    internal static func == (lhs: ComponentItem, rhs: ComponentItem) -> Bool {
        lhs.title == rhs.title
    }

    internal func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
}
