//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import UIKit

/// Adds helper functionality to any `UIViewController` instance through the `adyen` property.
extension AdyenScope where Base: UIViewController {
    
    /// Enables any `UIViewController` to access its top most presented view controller, e.g `viewController.adyen.topPresenter`.
    package var topPresenter: UIViewController {
        var topController: UIViewController = self.base
        while let presenter = topController.presentedViewController {
            topController = presenter
        }
        return topController
    }
    
    /// The content view controller to use when a secondary screen is pushed into
    /// a navigation stack. Navigation controller wrappers (e.g. picker screens)
    /// are unwrapped to their content, as a navigation controller cannot be pushed.
    package var secondaryScreenContent: UIViewController {
        (base as? UINavigationController)?.viewControllers.first ?? base
    }
    
}

extension UIResponder: AdyenCompatible {}
