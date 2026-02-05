//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest

extension UIBarButtonItem {
    func tap() throws {
        let unwrappedTarget = try XCTUnwrap(target)
        let unwrappedAction = try XCTUnwrap(action)
        
        _ = unwrappedTarget.perform(unwrappedAction)
    }
}
