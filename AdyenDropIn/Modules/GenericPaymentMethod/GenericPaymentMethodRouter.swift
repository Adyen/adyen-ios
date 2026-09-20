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
internal protocol GenericPaymentMethodRouting: AnyObject {
    func presentPaymentAction(for action: Action) async
    func dismiss()
}

@MainActor
internal class GenericPaymentMethodRouter: Router, GenericPaymentMethodRouting {

    // MARK: - Properties

    internal let rootViewController: UIViewController
    internal var childRouter: Router?
    private let paymentActionAssembler: PaymentActionAssemblerProtocol
    private weak var listener: GenericPaymentMethodRouterListener?

    // MARK: - Initializers

    internal init(
        viewController: UIViewController,
        paymentActionAssembler: PaymentActionAssemblerProtocol,
        listener: GenericPaymentMethodRouterListener
    ) {
        self.rootViewController = viewController
        self.paymentActionAssembler = paymentActionAssembler
        self.listener = listener
    }

    // MARK: - GenericPaymentMethodRouting

    internal func presentPaymentAction(for action: Action) async {
        guard let paymentActionRouter = await paymentActionAssembler.resolvePaymentActionRouter(
            for: action,
            listener: self
        ) else { return }

        childRouter = paymentActionRouter
        rootViewController.present(paymentActionRouter.rootViewController, animated: true)
    }

    internal func dismiss() {
        rootViewController.navigationController?.popViewController(animated: true)
        listener?.didDismissGenericPaymentMethod()
    }
}

// MARK: - PaymentActionRouterListener

extension GenericPaymentMethodRouter: PaymentActionRouterListener {

    internal func didDismissPaymentAction(completion: (() -> Void)?) {
        childRouter = nil
        completion?()
    }
}
