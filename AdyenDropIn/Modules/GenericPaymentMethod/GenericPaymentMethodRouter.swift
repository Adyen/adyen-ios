//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal protocol GenericPaymentMethodRouting: AnyObject {

}

internal class GenericPaymentMethodRouter: Router, GenericPaymentMethodRouting {

    // MARK: - Properties

    internal let rootViewController: UIViewController
    internal private(set) var childRouter: Router?

    // MARK: - Initializers

    init(
        viewController: UIViewController,
        childRouter: Router? = nil
    ) {
        self.rootViewController = viewController
        self.childRouter = childRouter
    }

    // MARK: - GenericPaymentMethodRouting
}
