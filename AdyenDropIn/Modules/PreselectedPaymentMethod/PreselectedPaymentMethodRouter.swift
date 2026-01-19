//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol PreselectedPaymentMethodRouterListener: AnyObject {
    func didDismissPreselectedPaymentMethod(completion: (() -> Void)?)
}

internal protocol PreselectedPaymentMethodRouting: AnyObject {
    func presentPaymentMethodList()
    func present(paymentComponent: any PresentableComponent, onCancel: @escaping (() -> Void))
    func present(actionComponent: any PresentableComponent, onCancel: (() -> Void)?)
    func dismiss(completion: (() -> Void)?)
}

internal class PreselectedPaymentMethodRouter: Router, PreselectedPaymentMethodRouting {

    // MARK: - Properties

    internal let rootViewController: UIViewController
    private weak var listener: PreselectedPaymentMethodRouterListener?
    private let paymentMethodListAssembler: PaymentMethodListAssemblerProtocol
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    internal private(set) var childRouter: Router?
    
    // MARK: - Initializers
    
    internal init(
        viewController: UIViewController,
        listener: PreselectedPaymentMethodRouterListener?,
        paymentMethodListAssembler: PaymentMethodListAssemblerProtocol,
        componentContainerAssembler: ComponentContainerAssemblerProtocol
    ) {
        self.rootViewController = viewController
        self.listener = listener
        self.paymentMethodListAssembler = paymentMethodListAssembler
        self.componentContainerAssembler = componentContainerAssembler
    }

    // MARK: - PreselectedPaymentMethodRouting

    internal func presentPaymentMethodList() {
        let paymentMethodListRouter = paymentMethodListAssembler.resolvePaymentMethodListRouter(delegate: self)
        self.childRouter = paymentMethodListRouter
        rootViewController.present(paymentMethodListRouter.rootViewController, animated: true)
    }

    internal func present(paymentComponent: any PresentableComponent, onCancel: @escaping (() -> Void)) {
        let componentContainerRouter = componentContainerAssembler.resolveComponentContainerRouter(
            for: paymentComponent,
            delegate: self,
            onCancel: onCancel
        )
        self.childRouter = componentContainerRouter
        rootViewController.present(componentContainerRouter.rootViewController, animated: true)
    }

    internal func present(actionComponent: any PresentableComponent, onCancel: (() -> Void)?) {
        let actionViewController = ActionPresentationHelper.viewController(
            for: actionComponent,
            onCancel: onCancel
        )
        rootViewController.present(actionViewController, animated: true)
    }

    internal func dismiss(completion: (() -> Void)?) {
        rootViewController.dismiss(animated: true) { [weak self] in
            self?.childRouter = nil
            self?.listener?.didDismissPreselectedPaymentMethod(completion: completion)
        }
    }
}

// MARK: - PaymentMethodListRouterListener

extension PreselectedPaymentMethodRouter: PaymentMethodListRouterListener {
    
    internal func didDismissPaymentMethodList(completion: (() -> Void)?) {
        rootViewController.presentingViewController?.dismiss(animated: true) { [weak self] in
            self?.childRouter = nil
            self?.listener?.didDismissPreselectedPaymentMethod(completion: completion)
        }
    }
}

// MARK: - ComponentContainerRouterListener

extension PreselectedPaymentMethodRouter: ComponentContainerRouterListener {
    
    internal func didDismissComponentContainer(completion: (() -> Void)?) {
        childRouter = nil
        completion?()
    }
}
