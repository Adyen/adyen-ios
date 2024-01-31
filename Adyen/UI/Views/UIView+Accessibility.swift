//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

@_documentation(visibility: internal)
public extension UIView {
    
    /// Marks the element as selected/not-selected by inserting/removing `.selected` into/from the `accessibilityTraits`
    ///
    /// - Parameter selected: Whether or not to mark the element as selected
    func accessibilityMarkAsSelected(_ selected: Bool) {
        if selected {
            accessibilityTraits.insert(.selected)
        } else {
            accessibilityTraits.remove(.selected)
        }
    }
}
