//
// Copyright (c) 2024 Adyen N.V.
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

/// Wrapper class that holds onto a weak reference of ``ViewControllerPresenter``.
/// It conforms to ``ViewControllerPresenter`` itself and forwards all ``ViewControllerPresenter`` calls to the reference.
///
/// To be used in places where a non optional presenter is required (e.g. to instantiate a different object)
@_spi(AdyenInternal)
public class WeakReferenceViewControllerPresenter: ViewControllerPresenter {
    
    private weak var presenter: ViewControllerPresenter?
    
    public init(_ presenter: ViewControllerPresenter) {
        self.presenter = presenter
    }
    
    public func presentViewController(_ viewController: UIViewController, animated: Bool) {
        presenter?.presentViewController(viewController, animated: animated)
    }
    
    public func dismissViewController(animated: Bool) {
        presenter?.dismissViewController(animated: animated)
    }
}
