//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// The way the stored payment prompt is presented by its parent module.
internal enum StoredPaymentPromptPresentationMode: Equatable {
    case pushed
    case modal
}

@MainActor
internal protocol StoredPaymentPromptRouterListener: AnyObject {
    func didDismissStoredPaymentPrompt()
}

@MainActor
internal protocol StoredPaymentPromptRouting: AnyObject {
    func present(actionViewController: UIViewController, onCancel: (() -> Void)?)
    func dismiss()
}

@MainActor
internal final class StoredPaymentPromptRouter: Router, StoredPaymentPromptRouting {

    internal let rootViewController: UIViewController
    internal var childRouter: Router? {
        nil
    }

    private weak var listener: StoredPaymentPromptRouterListener?
    private let presentationMode: StoredPaymentPromptPresentationMode

    internal init(
        viewController: UIViewController,
        presentationMode: StoredPaymentPromptPresentationMode,
        listener: StoredPaymentPromptRouterListener
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
        listener?.didDismissStoredPaymentPrompt()
    }
}
