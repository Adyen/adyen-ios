//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// So that any `UIViewController` instance will inherit the `adyen` scope.
/// :nodoc:
extension UIViewController: AdyenCompatible {}

/// Adds helper functionality to any `UIViewController` instance through the `adyen` property.
/// :nodoc:
public extension AdyenScope where Base: UIViewController {
    
    /// Enables any `UIViewController` to access its top most presented view controller, e.g `viewController.adyen.topPresenter`.
    /// :nodoc:
    var topPresenter: UIViewController {
        var topController: UIViewController = self.base
        while let presenter = topController.presentedViewController {
            topController = presenter
        }
        return topController
    }
    
}
