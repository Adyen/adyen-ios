//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension NSLayoutConstraint {

    class func activateConstrainst(_ constraints: [NSLayoutConstraint]) {
        constraints.forEach { constraint in
            if let view = constraint.firstItem as? UIView {
                view.translatesAutoresizingMaskIntoConstraints = false
            }
        }

        activate(constraints)
    }
}
