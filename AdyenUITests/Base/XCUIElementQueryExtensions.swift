//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest

internal extension XCUIElementQuery {
    internal var first: XCUIElement {
        return element(boundBy: 0)
    }
    
    internal var last: XCUIElement {
        return element(boundBy: count - 1)
    }
    
}
