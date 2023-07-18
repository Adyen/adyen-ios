//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

@_spi(AdyenInternal)
public protocol ViewControllerPresenter: AnyObject {
    
    func presentViewController(_ viewController: UIViewController, animated: Bool)
    func dismissViewController(animated: Bool)
}

@_spi(AdyenInternal)
extension UIViewController: ViewControllerPresenter {
    
    public func presentViewController(_ viewController: UIViewController, animated: Bool) {
        self.adyen.topPresenter.present(viewController, animated: animated)
    }
    
    public func dismissViewController(animated: Bool) {
        self.dismiss(animated: animated)
    }
}
