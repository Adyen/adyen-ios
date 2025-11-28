//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation
import SafariServices
import UIKit

internal protocol DropInRouting: Router, AnyObject { }

internal class DropInRouter: DropInRouting {
    
    // MARK: - Properties
    
    internal private(set) lazy var rootViewController: UIViewController = {
        resolveRootView()
    }()
    
    private let viewModel: DropInViewModelProtocol
    private let preselectedPaymentMethodAssembler: PreselectedPaymentMethodAssemblerProtocol
    private let paymentMethodListAssembler: PaymentMethodListAssemblerProtocol
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    internal private(set) var childRouter: Router?
    
    // MARK: - Initializers
    
    internal init(
        viewModel: DropInViewModelProtocol,
        preselectedPaymentMethodAssembler: PreselectedPaymentMethodAssemblerProtocol,
        paymentMethodListAssembler: PaymentMethodListAssemblerProtocol,
        componentContainerAssembler: ComponentContainerAssemblerProtocol
    ) {
        self.viewModel = viewModel
        self.preselectedPaymentMethodAssembler = preselectedPaymentMethodAssembler
        self.paymentMethodListAssembler = paymentMethodListAssembler
        self.componentContainerAssembler = componentContainerAssembler
    }

    // MARK: - Private
    
    private func resolveRootView() -> UIViewController {
        switch viewModel.root {
        case let .preselected(paymentComponent):
            let preselectedPaymentMethodRouter = preselectedPaymentMethodAssembler.resolvePreselectedPaymentMethodRouter(
                delegate: self,
                component: paymentComponent,
                title: viewModel.title
            )
            self.childRouter = preselectedPaymentMethodRouter
            let preselectedPaymentMethodViewController = preselectedPaymentMethodRouter.rootViewController
            let navigationController = UINavigationController(rootViewController: preselectedPaymentMethodViewController)
            return navigationController
        case let .component(paymentComponent):
            let componentContainerRouter = componentContainerAssembler.resolveComponentContainerRouter(
                for: paymentComponent,
                delegate: self,
                onCancel: nil
            )
            self.childRouter = componentContainerRouter
            return componentContainerRouter.rootViewController
        case .paymentMethodList:
            let paymentMethodListRouter = paymentMethodListAssembler.resolvePaymentMethodListRouter(delegate: self)
            self.childRouter = paymentMethodListRouter
            return paymentMethodListRouter.rootViewController
        }
    }
}

// MARK: - PreselectedPaymentMethodRouterListener

extension DropInRouter: PreselectedPaymentMethodRouterListener {
    internal func didDismissPreselectedPaymentMethod(completion: (() -> Void)?) {
        childRouter = nil
        completion?()
    }
}

// MARK: - PaymentMethodListRouterListener

extension DropInRouter: PaymentMethodListRouterListener {
    
    internal func didDismissPaymentMethodList(completion: (() -> Void)?) {
        childRouter = nil
        completion?()
    }
}

// MARK: - ComponentContainerRouterListener

extension DropInRouter: ComponentContainerRouterListener {
    
    internal func didDismissComponentContainer(completion: (() -> Void)?) {
        childRouter = nil
        completion?()
    }
}
