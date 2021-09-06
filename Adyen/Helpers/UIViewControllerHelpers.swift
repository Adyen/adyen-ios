//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import UIKit

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

/// :nodoc:
extension UIResponder: AdyenCompatible {}

extension AdyenScope where Base: UIResponder {
    /// :nodoc:
    func updatePreferredContentSize() {
        if let consumer = base as? PreferredContentSizeConsumer {
            consumer.willUpdatePreferredContentSize()
        }
        base.next?.adyen.updatePreferredContentSize()
        if let consumer = base as? PreferredContentSizeConsumer {
            consumer.didUpdatePreferredContentSize()
        }
    }
}

/// :nodoc:
public protocol PreferredContentSizeConsumer {

    /// :nodoc:
    func didUpdatePreferredContentSize()

    /// :nodoc:
    func willUpdatePreferredContentSize()
}
