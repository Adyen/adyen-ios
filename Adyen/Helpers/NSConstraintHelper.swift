//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// So that any `NSLayoutConstraint` instance will inherit the `adyen` scope.
/// :nodoc:
extension NSLayoutConstraint: AdyenCompatible {}

/// Adds helper functionality to any `NSLayoutConstraint` instance through the `adyen` property.
extension AdyenScope where Base: NSLayoutConstraint {

    /// Apply `priority` to this instance of `NSLayoutConstraint`
    public func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        base.priority = priority
        return base
    }

}
