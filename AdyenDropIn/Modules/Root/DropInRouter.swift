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
        resolveRootViewController()
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

    private func resolveRootViewController() -> UIViewController {
        let router: Router

        switch viewModel.root {
        case let .preselected(paymentComponent):
            router = preselectedPaymentMethodAssembler.resolvePreselectedPaymentMethodRouter(
                listener: self,
                component: paymentComponent,
                title: viewModel.title
            )
        case let .component(paymentComponent):
            router = componentContainerAssembler.resolveComponentContainerRouter(
                for: paymentComponent,
                listener: self
            )
        case .paymentMethodList:
            router = paymentMethodListAssembler.resolvePaymentMethodListRouter(
                listener: self
            )
        }

        self.childRouter = router
        return UINavigationController(rootViewController: router.rootViewController)
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
    
    /// Dismissing the payment method list dismisses the drop in it is the root of.
    internal func didDismissPaymentMethodList(completion: (() -> Void)?) {
        dismissDropIn(completion: completion)
    }
}

// MARK: - ComponentContainerRouterListener

extension DropInRouter: ComponentContainerRouterListener {
    
    internal func didDismissComponentContainer(completion: (() -> Void)?) {
        childRouter = nil
        completion?()
    }
}
