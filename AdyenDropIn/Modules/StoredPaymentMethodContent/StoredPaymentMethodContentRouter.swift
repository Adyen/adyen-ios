//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// The way the stored payment method content is presented by its parent module.
internal enum StoredPaymentMethodContentPresentation: Equatable {
    case pushed
    case modal
}

@MainActor
internal protocol StoredPaymentMethodContentRouterListener: AnyObject {
    func didDismissStoredPaymentMethodContent()
}

@MainActor
internal final class StoredPaymentMethodContentRouter: Router, StoredPaymentMethodContentRouting {

    internal let rootViewController: UIViewController
    internal var childRouter: Router? {
        nil
    }

    private weak var listener: StoredPaymentMethodContentRouterListener?
    private let presentationMode: StoredPaymentMethodContentPresentation

    internal init(
        viewController: UIViewController,
        presentationMode: StoredPaymentMethodContentPresentation,
        listener: StoredPaymentMethodContentRouterListener
    ) {
        self.rootViewController = viewController
        self.presentationMode = presentationMode
        self.listener = listener
    }

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
        switch presentationMode {
        case .pushed:
            rootViewController.navigationController?.popViewController(animated: true)
        case .modal:
            rootViewController.navigationController?.dismiss(animated: true)
        }
        listener?.didDismissStoredPaymentMethodContent()
    }
}
