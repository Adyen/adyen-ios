//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation
import UIKit

internal protocol DropInRouterListener: AnyObject {
    func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent)
    func didFail(with error: any Error, from component: any PaymentComponent)
    func didCancel(component: any PaymentComponent)
    
    func didOpenExternalApplication(component: ActionComponent)
    func didProvide(_ data: ActionComponentData, from component: ActionComponent)
    func didComplete(from component: ActionComponent)
    func didFail(with error: Error, from component: ActionComponent)
}

internal protocol Router: AnyObject {
    var rootViewController: UIViewController { get }
    func stopLoading()
}

extension Router {
    internal func stopLoading() { /* Optional implementation */ }
}

internal protocol DropInRouting: Router, AnyObject {
    func handle(action: Action)
    func present(_ viewController: UIViewController, animated: Bool)
    
    func openExternalApplication(component: any ActionComponent)
    func provide(_ data: ActionComponentData, from component: any ActionComponent)
    func complete(from component: any ActionComponent)
    func fail(with error: any Error, from component: any ActionComponent)
    func cancel(with error: any Error, from component: any ActionComponent)
}

internal class DropInRouter: DropInRouting {
    
    // MARK: - Properties
    
    internal private(set) lazy var rootViewController: UIViewController = {
        resolveRootView()
    }()
    
    private let viewModel: DropInViewModelProtocol
    private weak var listener: DropInRouterListener?
    private let preselectedPaymentMethodAssembler: PreselectedPaymentMethodAssemblerProtocol
    private let paymentMethodListAssembler: PaymentMethodListAssemblerProtocol
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    
    private var childRouter: Router?
    
    // MARK: - Initializers
    
    internal init(
        viewModel: DropInViewModelProtocol,
        listener: DropInRouterListener,
        preselectedPaymentMethodAssembler: PreselectedPaymentMethodAssemblerProtocol,
        paymentMethodListAssembler: PaymentMethodListAssemblerProtocol,
        componentContainerAssembler: ComponentContainerAssemblerProtocol
    ) {
        self.viewModel = viewModel
        self.listener = listener
        self.preselectedPaymentMethodAssembler = preselectedPaymentMethodAssembler
        self.paymentMethodListAssembler = paymentMethodListAssembler
        self.componentContainerAssembler = componentContainerAssembler
    }
    
    // MARK: - DropInRouting
    
    internal func handle(action: Action) {
        viewModel.handle(action: action)
    }
    
    internal func present(_ viewController: UIViewController, animated: Bool) {
        childRouter?.rootViewController.present(viewController, animated: animated)
    }
    
    internal func openExternalApplication(component: any ActionComponent) {
        listener?.didOpenExternalApplication(component: component)
    }
    
    internal func provide(_ data: ActionComponentData, from component: any ActionComponent) {
        listener?.didProvide(data, from: component)
    }
    
    internal func complete(from component: any ActionComponent) {
        listener?.didComplete(from: component)
    }
    
    internal func fail(with error: any Error, from component: any ActionComponent) {
        listener?.didFail(with: error, from: component)
    }
    
    internal func cancel(with error: any Error, from component: any ActionComponent) {
        stopLoading()
    }
    
    // MARK: - Router
    
    internal func stopLoading() {
        childRouter?.stopLoading()
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
                delegate: self
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
        
    internal func didPresentPaymentMethodList() {
        let paymentMethodListRouter = paymentMethodListAssembler.resolvePaymentMethodListRouter(delegate: self)
        self.childRouter = paymentMethodListRouter
        rootViewController.present(paymentMethodListRouter.rootViewController, animated: true)
    }
}

// MARK: - PaymentMethodListRouterListener, ComponentContainerRouterListener

extension DropInRouter: PaymentMethodListRouterListener, ComponentContainerRouterListener {
        
    internal func didDismiss(completion: (() -> Void)?) {
        // TODO: - Decide wether dismissal this logic belongs to dropIn or merchant's side
        rootViewController.presentingViewController?.dismiss(animated: true)
        childRouter = nil
    }
    
    internal func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent) {
        listener?.didSubmit(data, from: component)
    }
    
    internal func didFail(with error: any Error, from component: any PaymentComponent) {
        listener?.didFail(with: error, from: component)
    }
    
    internal func didCancel(component: any PaymentComponent) {
        listener?.didCancel(component: component)
    }
}
