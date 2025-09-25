//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol PreselectedPaymentMethodRouterProtocol: AnyObject {
    func dismiss(completion: (() -> Void)?)
    func showAllPaymentMethods()
    func proceed(with paymentComponent: PresentableComponent)
}

internal protocol PreselectedPaymentMethodRouterDelegate: AnyObject {
    func showAllPaymentMethods()
}

internal class PreselectedPaymentMethodRouter: Router, PreselectedPaymentMethodRouterProtocol {
    
    // MARK: - Properties

    internal let rootViewController: UIViewController
    private weak var delegate: PreselectedPaymentMethodRouterDelegate?
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    private var componentContainerRouter: Router?

    // MARK: - Initializers
    
    internal init(
        viewController: UIViewController,
        delegate: PreselectedPaymentMethodRouterDelegate?,
        componentContainerAssembler: ComponentContainerAssemblerProtocol
    ) {
        self.rootViewController = viewController
        self.delegate = delegate
        self.componentContainerAssembler = componentContainerAssembler
    }
    
    // MARK: - Router
    
    internal func handle(action: Action) {
        componentContainerRouter?.handle(action: action)
    }

    // MARK: - PreselectedPaymentMethodRouterProtocol

    internal func dismiss(completion: (() -> Void)?) {
        rootViewController.dismiss(animated: true, completion: completion)
    }

    internal func showAllPaymentMethods() {
        delegate?.showAllPaymentMethods()
    }

    internal func proceed(with paymentComponent: any PresentableComponent) {
        // TODO: - Handle logic with preselected payment method
//        delegate?.didProceed(with: paymentComponent)

        let componentContainerRouter = componentContainerAssembler.resolveComponentContainerRouter(
            for: paymentComponent,
            delegate: self
        )
        self.componentContainerRouter = componentContainerRouter
        rootViewController.present(componentContainerRouter.rootViewController, animated: true)
    }
}

extension PreselectedPaymentMethodRouter: ComponentContainerRouterDelegate {

    func didSubmit(_ data: Adyen.PaymentComponentData, from component: any Adyen.PaymentComponent) {
        // TODO: - Logic didSubmit
    }
    
    func didFail(with error: any Error) {
        // TODO: - Logic didFail
    }
    
    func didCancel(component: any Adyen.PaymentComponent) {
        // TODO: - Logic didCancel
    }
    
    // MARK: - ActionComponentDelegate
    
    func didOpenExternalApplication(component: any ActionComponent) {
        // TODO: - Logic to open external app
    }
    
    func didProvide(_ data: ActionComponentData, from component: any ActionComponent) {
        // TODO: - Logic to handle action details
    }
    
    func didComplete(from component: any ActionComponent) {
        // TODO: - Logic to handle action completion
    }
    
    func didFail(with error: any Error, from component: any ActionComponent) {
        // TODO: - Logic to handle action error
    }
}
