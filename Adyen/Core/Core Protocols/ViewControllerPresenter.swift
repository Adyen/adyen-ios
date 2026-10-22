//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

package protocol ViewControllerPresenter: AnyObject {
    
    func presentViewController(_ viewController: UIViewController, animated: Bool)
    func dismissViewController(animated: Bool)
}

/// Opt-in capability for view controllers whose secondary screens can be
/// presented by an injected presenter instead of the default modal presentation.
///
/// The Drop in injects a presenter that pushes secondary screens onto its
/// navigation stack. Standalone components keep the slot empty and fall back
/// to presenting modally.
package protocol SecondaryScreenNavigable: AnyObject {
    var secondaryScreenPresenter: ViewControllerPresenter? { get set }
}

extension UIViewController: ViewControllerPresenter {
    
    package func presentViewController(_ viewController: UIViewController, animated: Bool) {
        if let presenter = adyen.injectedSecondaryScreenPresenter {
            presenter.presentViewController(viewController.adyen.secondaryScreenContent, animated: animated)
        } else {
            self.adyen.topPresenter.present(viewController, animated: animated)
        }
    }
    
    package func dismissViewController(animated: Bool) {
        if let presenter = adyen.injectedSecondaryScreenPresenter {
            presenter.dismissViewController(animated: animated)
        } else {
            self.dismiss(animated: animated)
        }
    }
}

private extension AdyenScope where Base: UIViewController {
    
    /// The nearest injected secondary screen presenter, searching this view
    /// controller and its parents (e.g. a form inside a `SecuredViewController`
    /// resolves the presenter injected on the wrapper).
    var injectedSecondaryScreenPresenter: ViewControllerPresenter? {
        sequence(first: base, next: \.parent)
            .lazy
            .compactMap { ($0 as? SecondaryScreenNavigable)?.secondaryScreenPresenter }
            .first
    }
}

/// Wrapper class that holds onto a weak reference of ``ViewControllerPresenter``.
/// It conforms to ``ViewControllerPresenter`` itself and forwards all ``ViewControllerPresenter`` calls to the reference.
///
/// To be used in places where a non optional presenter is required (e.g. to instantiate a different object)
package class WeakReferenceViewControllerPresenter: ViewControllerPresenter {

    private weak var presenter: ViewControllerPresenter?
    
    package init(_ presenter: ViewControllerPresenter) {
        self.presenter = presenter
    }
    
    package func presentViewController(_ viewController: UIViewController, animated: Bool) {
        presenter?.presentViewController(viewController, animated: animated)
    }
    
    package func dismissViewController(animated: Bool) {
        presenter?.dismissViewController(animated: animated)
    }
}
