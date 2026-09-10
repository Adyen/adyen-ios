//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal protocol GenericPaymentMethodRouting: AnyObject {
    func present(actionViewController: UIViewController)
    func dismiss()
}

internal class GenericPaymentMethodRouter: Router, GenericPaymentMethodRouting {

    // MARK: - Properties

    internal let rootViewController: UIViewController
    internal private(set) var childRouter: Router?

    // MARK: - Initializers

    internal init(
        viewController: UIViewController,
        childRouter: Router? = nil
    ) {
        self.rootViewController = viewController
        self.childRouter = childRouter
    }

    // MARK: - GenericPaymentMethodRouting

    internal func present(actionViewController: UIViewController) {
        rootViewController.navigationController?.presentViewController(actionViewController, animated: true)
    }

    internal func dismiss() {
        rootViewController.navigationController?.popViewController(animated: true)
    }
}
