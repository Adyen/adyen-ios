//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest

internal extension XCUIElement {
    func tapAndType(_ text: String) {
        tap()
        typeText(text)
    }
}
