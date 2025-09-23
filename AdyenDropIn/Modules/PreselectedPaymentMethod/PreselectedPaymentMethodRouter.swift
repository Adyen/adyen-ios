//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol PreselectedPaymentMethodRouterProtocol: AnyObject {
    var rootViewController: UIViewController { get }
    var delegate: PreselectedPaymentMethodRouterDelegate? { get set }
    func dismiss(completion: (() -> Void)?)
    func showAllPaymentMethods()
    func proceed(with paymentComponent: PresentableComponent)
}

internal protocol PreselectedPaymentMethodRouterDelegate: AnyObject {
    func showAllPaymentMethods()
}

internal class PreselectedPaymentMethodRouter: PreselectedPaymentMethodRouterProtocol {
    
    // MARK: - Properties

    internal var view: UIViewController?
    internal weak var delegate: PreselectedPaymentMethodRouterDelegate?
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol

    // MARK: - Initializers
    
    internal init(componentContainerAssembler: ComponentContainerAssemblerProtocol) {
        self.componentContainerAssembler = componentContainerAssembler
    }

    // MARK: - PreselectedPaymentMethodRouterProtocol

    internal var rootViewController: UIViewController {
        guard let view else {
            fatalError("Router's view was not set.")
        }
        return view
    }

    internal func dismiss(completion: (() -> Void)?) {
        view?.dismiss(animated: true, completion: completion)
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
