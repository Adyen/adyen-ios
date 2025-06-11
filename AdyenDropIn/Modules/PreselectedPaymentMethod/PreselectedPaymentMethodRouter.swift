//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

internal protocol PreselectedPaymentMethodRouterProtocol {
    func dismiss(completion: (() -> Void)?)
    func showAllPaymentMethods()
    func present(componentViewController: UIViewController)
}

internal class PreselectedPaymentMethodRouter: PreselectedPaymentMethodRouterProtocol {

    // MARK: - Properties

    private let paymentMethodListAssembler: PaymentMethodListAssemblerProtocol
    internal weak var view: UIViewController?

    // MARK: - Initializers

    internal init(paymentMethodListAssembler: PaymentMethodListAssemblerProtocol) {
        self.paymentMethodListAssembler = paymentMethodListAssembler
    }

    // MARK: - PreselectedPaymentMethodRouterProtocol

    internal func dismiss(completion: (() -> Void)?) {
        view?.dismiss(animated: true, completion: completion)
    }

    internal func showAllPaymentMethods() {
        let paymentMethodListView = paymentMethodListAssembler.resolvePaymentMethodListView()

        let navigationViewController = UINavigationController(rootViewController: paymentMethodListView)
        view?.present(navigationViewController, animated: true)
    }

    func present(componentViewController: UIViewController) {
        // TODO: - Handle logic with preselected payment method
        view?.present(componentViewController, animated: true)
    }
}
