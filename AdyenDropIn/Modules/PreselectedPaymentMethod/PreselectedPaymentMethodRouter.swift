//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol PreselectedPaymentMethodRouterListener: AnyObject {
    func didPresentPaymentMethodList()
    func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent)
    func didFail(with error: any Error, from component: any PaymentComponent)
    func didCancel(component: any PaymentComponent)
}

internal protocol PreselectedPaymentMethodRouting: AnyObject, PaymentComponentRouting {
    func presentPaymentMethodList()
    func proceed(with paymentComponent: PresentableComponent)
}

internal class PreselectedPaymentMethodRouter: Router, PreselectedPaymentMethodRouting {
    
    // MARK: - Properties

    internal let rootViewController: UIViewController
    private let viewModel: RoutablePreselectedPaymentMethodViewModel
    private weak var listener: PreselectedPaymentMethodRouterListener?
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    private var componentContainerRouter: Router?

    // MARK: - Initializers
    
    internal init(
        viewController: UIViewController,
        viewModel: RoutablePreselectedPaymentMethodViewModel,
        listener: PreselectedPaymentMethodRouterListener?,
        componentContainerAssembler: ComponentContainerAssemblerProtocol
    ) {
        self.rootViewController = viewController
        self.viewModel = viewModel
        self.listener = listener
        self.componentContainerAssembler = componentContainerAssembler
    }

    // MARK: - PreselectedPaymentMethodRouting

    internal func presentPaymentMethodList() {
        listener?.didPresentPaymentMethodList()
    }

    internal func proceed(with paymentComponent: any PresentableComponent) {
        let componentContainerRouter = componentContainerAssembler.resolveComponentContainerRouter(
            for: paymentComponent,
            delegate: self
        )
        self.componentContainerRouter = componentContainerRouter
        rootViewController.present(componentContainerRouter.rootViewController, animated: true)
    }
    
    internal func submit(_ data: PaymentComponentData, from component: any PaymentComponent) {
        listener?.didSubmit(data, from: component)
    }
    
    internal func fail(with error: any Error, from component: any PaymentComponent) {
        listener?.didFail(with: error, from: component)
    }
    
    internal func cancel(component: any PaymentComponent) {
        rootViewController.dismiss(animated: true)
        listener?.didCancel(component: component)
    }
    
    // MARK: - Router
    
    internal func stopLoading() {
        viewModel.stopLoading()
    }
}

// MARK: - ComponentContainerRouterListener

extension PreselectedPaymentMethodRouter: ComponentContainerRouterListener {
    
    func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent) {
        listener?.didSubmit(data, from: component)
    }
    
    func didFail(with error: any Error, from component: any PaymentComponent) {
        listener?.didFail(with: error, from: component)
    }
    
    func didCancel(component: any PaymentComponent) {
        stopLoading()
        componentContainerRouter = nil
        listener?.didCancel(component: component)
    }
}
