//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenActions)
    import AdyenActions
#endif
import Foundation
import UIKit

// sourcery:AutoMockable
@MainActor
internal protocol ComponentContainerRouterListener: AnyObject {
    func didDismissComponentContainer(completion: (() -> Void)?)
}

// sourcery:AutoMockable
@MainActor
internal protocol ComponentContainerRouting: Router {
    func present(paymentComponent: PaymentComponent)
    func dismiss(completion: (() -> Void)?)
}

@MainActor
internal class ComponentContainerRouter: ComponentContainerRouting {

    // MARK: - Properties

    private let viewController: ComponentContainerViewController
    private weak var listener: ComponentContainerRouterListener?
    internal private(set) var childRouter: Router?

    // MARK: - Initializers

    internal init(
        viewController: ComponentContainerViewController,
        component: PaymentComponent,
        listener: ComponentContainerRouterListener
    ) {
        self.viewController = viewController
        self.listener = listener
        // This router owns the navigation below the payment form,
        // so it also decides how the component's secondary screens appear.
        (component as? SecondaryScreenPresentingComponent)?.secondaryScreenPresenter = self
    }

    // MARK: - Router

    internal var rootViewController: UIViewController {
        viewController
    }

    // MARK: - ComponentContainerRouting

    internal func present(paymentComponent: any PaymentComponent) {
        let componentViewController = paymentComponent.viewController
        rootViewController.navigationController?.pushViewController(componentViewController, animated: true)
    }

    internal func dismiss(completion: (() -> Void)?) {
        rootViewController.dismiss(animated: true) { [weak self] in
            self?.listener?.didDismissComponentContainer(completion: completion)
        }
    }
}

// MARK: - ViewControllerPresenter

/// Secondary screens are entries of Drop-in's navigation stack:
/// they slide in with a back arrow, and the payment form below keeps its state.
extension ComponentContainerRouter: ViewControllerPresenter {

    internal func presentViewController(_ viewController: UIViewController, animated: Bool) {
        rootViewController.navigationController?.pushViewController(viewController, animated: animated)
    }

    /// Closes the newest secondary screen.
    /// Does nothing once the shopper is back on the payment form, for example after tapping back.
    internal func dismissViewController(animated: Bool) {
        guard let navigationController = rootViewController.navigationController,
              navigationController.topViewController !== rootViewController else { return }
        navigationController.popViewController(animated: animated)
    }
}
