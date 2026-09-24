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
    internal var childRouter: Router?

    // MARK: - Initializers

    internal init(
        viewController: ComponentContainerViewController,
        listener: ComponentContainerRouterListener
    ) {
        self.viewController = viewController
        self.listener = listener
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
