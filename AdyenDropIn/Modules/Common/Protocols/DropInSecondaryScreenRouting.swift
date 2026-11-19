//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// It shows the component's secondary screens, like pickers or the address lookup, on its own navigation stack:
/// they slide in with a back arrow, and the form below keeps its state.
@MainActor
internal protocol DropInSecondaryScreenRouting: Router, ViewControllerPresenter {}

extension DropInSecondaryScreenRouting {

    /// Lets this router show the component's secondary screens.
    /// We need this to inject the router to the PaymentComponent, as the PaymentComponent is created before the router is created.
    internal func routeSecondaryScreens(of component: PaymentComponent) {
        (component as? SecondaryScreenPresentingComponent)?.presenter.route(through: WeakReferenceViewControllerPresenter(self))
    }

    internal func presentViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.largeTitleDisplayMode = .never
        rootViewController.navigationController?.pushViewController(viewController, animated: animated)
    }

    internal func dismissViewController(_ viewController: UIViewController, animated: Bool) {
        guard let navigationController = rootViewController.navigationController,
              let rootIndex = navigationController.viewControllers.firstIndex(of: rootViewController),
              let index = navigationController.viewControllers.firstIndex(of: viewController),
              index > rootIndex else { return }
        navigationController.popToViewController(navigationController.viewControllers[index - 1], animated: animated)
    }
}
