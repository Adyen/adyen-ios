//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

@MainActor
internal protocol StoredPaymentMethodContentRouterListener: AnyObject {
    /// Asks the parent module to unwind the stored payment method content it presented.
    func dismissStoredPaymentMethodContent()
}

@MainActor
internal final class StoredPaymentMethodContentRouter: Router, StoredPaymentMethodContentRouting {

    internal let rootViewController: UIViewController
    internal var childRouter: Router? {
        nil
    }

    private weak var listener: StoredPaymentMethodContentRouterListener?

    internal init(
        viewController: UIViewController,
        listener: StoredPaymentMethodContentRouterListener
    ) {
        self.rootViewController = viewController
        self.listener = listener
    }

    internal func dismiss() {
        // The parent module presented this content, so it also owns unwinding it.
        listener?.dismissStoredPaymentMethodContent()
    }
}
