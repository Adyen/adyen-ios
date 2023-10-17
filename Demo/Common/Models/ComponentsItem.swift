//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal struct ComponentsItem: Hashable {

    internal let title: String
    internal let subtitle: String?
    
    internal var isApplePay: Bool { title == "Apple Pay" }
    
    internal let selectionHandler: () -> Void
    
    internal init(
        title: String,
        subtitle: String? = nil,
        selectionHandler: @escaping (() -> Void)
    ) {
        self.title = title
        self.subtitle = subtitle
        self.selectionHandler = selectionHandler
    }

    internal static func == (lhs: ComponentsItem, rhs: ComponentsItem) -> Bool {
        lhs.title == rhs.title && lhs.subtitle == rhs.subtitle
    }

    internal func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(subtitle)
    }
    
}
