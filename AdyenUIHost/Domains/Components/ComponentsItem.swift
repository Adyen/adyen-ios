//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal struct ComponentsItem {
    
    internal var title: String?
    
    internal var selectionHandler: (() -> Void)?
    
    internal init(title: String? = nil, selectionHandler: (() -> Void)? = nil) {
        self.title = title
        self.selectionHandler = selectionHandler
    }
    
}
