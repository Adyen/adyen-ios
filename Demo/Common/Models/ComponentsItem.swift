//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct ComponentsItem: Hashable {

    let title: String
    
    var isApplePay: Bool { title == "Apple Pay" }
    
    let selectionHandler: () -> Void
    
    init(title: String, selectionHandler: @escaping (() -> Void)) {
        self.title = title
        self.selectionHandler = selectionHandler
    }

    static func == (lhs: ComponentsItem, rhs: ComponentsItem) -> Bool {
        lhs.title == rhs.title
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
}
