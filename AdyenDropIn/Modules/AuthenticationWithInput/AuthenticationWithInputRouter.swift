//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal enum AuthenticationPresentationMode: Equatable {
    case pushed
    case modal
}

@MainActor
internal protocol AuthenticationWithInputRouterListener: AnyObject {
    func didDismissAuthenticationWithInput()
}

@MainActor
internal protocol AuthenticationWithInputRouting: AnyObject {
    func present(actionViewController: UIViewController, onCancel: (() -> Void)?)
    func dismiss()
}

@MainActor
internal final class AuthenticationWithInputRouter: Router, AuthenticationWithInputRouting {

    internal let rootViewController: UIViewController
    internal var childRouter: Router? {
        nil
    }

    private weak var listener: AuthenticationWithInputRouterListener?
    private let presentationMode: AuthenticationPresentationMode

    internal init(
        viewController: UIViewController,
        presentationMode: AuthenticationPresentationMode,
        listener: AuthenticationWithInputRouterListener
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
        listener?.didDismissAuthenticationWithInput()
    }
}
