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
internal protocol ComponentContainerRouting: AnyObject {
    func present(paymentComponent: PaymentComponent)
    func presentPaymentAction(for action: Action) async
    func dismiss(completion: (() -> Void)?)
}

@MainActor
internal class ComponentContainerRouter: Router, ComponentContainerRouting {

    // MARK: - Properties

    private let viewController: ComponentContainerViewController
    private let paymentActionAssembler: PaymentActionAssemblerProtocol
    private weak var listener: ComponentContainerRouterListener?
    internal var childRouter: Router?

    // MARK: - Initializers

    internal init(
        viewController: ComponentContainerViewController,
        paymentActionAssembler: PaymentActionAssemblerProtocol,
        listener: ComponentContainerRouterListener
    ) {
        self.viewController = viewController
        self.paymentActionAssembler = paymentActionAssembler
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

    internal func presentPaymentAction(for action: Action) async {
        guard let paymentActionRouter = await paymentActionAssembler.resolvePaymentActionRouter(
            for: action,
            listener: self
        ) else { return }

        childRouter = paymentActionRouter
        rootViewController.present(paymentActionRouter.rootViewController, animated: true)
    }

    internal func dismiss(completion: (() -> Void)?) {
        rootViewController.dismiss(animated: true) { [weak self] in
            self?.listener?.didDismissComponentContainer(completion: completion)
        }
    }
}

// MARK: - PaymentActionRouterListener

extension ComponentContainerRouter: PaymentActionRouterListener {

    internal func didDismissPaymentAction(completion: (() -> Void)?) {
        childRouter = nil
        completion?()
    }
}
