//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol PreselectedPaymentMethodRouterDelegate: AnyObject {
    func showAllPaymentMethods()
    func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent)
    func didFail(with error: any Error, from component: any PaymentComponent)
    func didCancel(component: any PaymentComponent)
}

internal protocol PreselectedPaymentMethodRouterProtocol: AnyObject {
    func showAllPaymentMethods()
    func proceed(with paymentComponent: PresentableComponent)
    
    func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent)
    func didFail(with error: any Error, from component: any PaymentComponent)
    func didCancelPreselect(component: any PaymentComponent)
}

internal class PreselectedPaymentMethodRouter: Router, PreselectedPaymentMethodRouterProtocol {
    
    // MARK: - Properties

    internal let rootViewController: UIViewController
    private let viewModel: RoutablePreselectedPaymentMethodViewModel
    private weak var delegate: PreselectedPaymentMethodRouterDelegate?
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    private var componentContainerRouter: Router?

    // MARK: - Initializers
    
    internal init(
        viewController: UIViewController,
        viewModel: RoutablePreselectedPaymentMethodViewModel,
        delegate: PreselectedPaymentMethodRouterDelegate?,
        componentContainerAssembler: ComponentContainerAssemblerProtocol
    ) {
        self.rootViewController = viewController
        self.viewModel = viewModel
        self.delegate = delegate
        self.componentContainerAssembler = componentContainerAssembler
    }

    // MARK: - PreselectedPaymentMethodRouterProtocol

    internal func showAllPaymentMethods() {
        delegate?.showAllPaymentMethods()
    }

    internal func proceed(with paymentComponent: any PresentableComponent) {
        let componentContainerRouter = componentContainerAssembler.resolveComponentContainerRouter(
            for: paymentComponent,
            delegate: self
        )
        self.componentContainerRouter = componentContainerRouter
        rootViewController.present(componentContainerRouter.rootViewController, animated: true)
    }
    
    internal func didCancelPreselect(component: any PaymentComponent) {
        rootViewController.dismiss(animated: true)
        delegate?.didCancel(component: component)
    }
    
    // MARK: - Router
    
    internal func stopLoading() {
        viewModel.stopLoading()
    }
}

extension PreselectedPaymentMethodRouter: ComponentContainerRouterDelegate {

    func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent) {
        delegate?.didSubmit(data, from: component)
    }
    
    func didFail(with error: any Error, from component: any PaymentComponent) {
        delegate?.didFail(with: error, from: component)
    }
    
    func didCancel(component: any PaymentComponent) {
        stopLoading()
        componentContainerRouter = nil
        delegate?.didCancel(component: component)
    }
}
