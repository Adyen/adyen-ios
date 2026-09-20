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

internal protocol DropInRouting: Router, DropInDismissing, AnyObject {}

@MainActor
internal class DropInRouter: DropInRouting {
    
    // MARK: - Properties
    
    internal private(set) lazy var rootViewController: UIViewController = {
        resolveRootView()
    }()
    
    private let viewModel: DropInViewModelProtocol
    private let preselectedPaymentMethodAssembler: PreselectedPaymentMethodAssemblerProtocol
    private let paymentMethodListAssembler: PaymentMethodListAssemblerProtocol
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    internal var childRouter: Router?
    
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
            return UINavigationController(rootViewController: preselectedPaymentMethodViewController)
        case let .component(paymentComponent):
            let componentContainerRouter = componentContainerAssembler.resolveComponentContainerRouter(
                for: paymentComponent,
                listener: self
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

// MARK: - DropInDismissing

extension DropInRouter {

    internal func dismissDropIn(completion: (() -> Void)?) {
        // Dismissing the root itself only tears down what is presented on top of it,
        // so the drop in is dismissed by the view controller presenting it.
        let dismissingViewController = rootViewController.presentingViewController ?? rootViewController

        dismissingViewController.dismiss(animated: true) { [weak self] in
            self?.childRouter = nil
            completion?()
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
