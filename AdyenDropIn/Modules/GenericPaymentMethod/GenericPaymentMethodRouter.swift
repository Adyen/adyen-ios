//
// Copyright (c) 2026 Adyen N.V.
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
internal protocol GenericPaymentMethodRouterListener: AnyObject {
    func didDismissGenericPaymentMethod()
}

// sourcery:AutoMockable
@MainActor
internal protocol GenericPaymentMethodRouting: Router {
    func present(actionViewController: UIViewController, onCancel: (() -> Void)?)
    func dismiss()
}

@MainActor
internal class GenericPaymentMethodRouter: GenericPaymentMethodRouting {

    // MARK: - Properties

    internal let rootViewController: UIViewController
    internal var childRouter: Router?
    private weak var listener: GenericPaymentMethodRouterListener?

    // MARK: - Initializers

    internal init(
        viewController: UIViewController,
        listener: GenericPaymentMethodRouterListener
    ) {
        self.rootViewController = viewController
        self.listener = listener
    }

    // MARK: - GenericPaymentMethodRouting

    internal func present(
        actionViewController: UIViewController,
        onCancel: (() -> Void)?
    ) {
        let actionViewController = ActionPresentationHelper.viewController(
            for: actionViewController,
            onCancel: onCancel
        )
        rootViewController.present(actionViewController, animated: true)
    }

    internal func dismiss() {
        rootViewController.navigationController?.popViewController(animated: true)
        listener?.didDismissGenericPaymentMethod()
    }
}
