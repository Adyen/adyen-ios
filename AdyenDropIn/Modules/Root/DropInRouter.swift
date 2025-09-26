//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation
import UIKit

internal protocol DropInRouterDelegate: AnyObject {
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
}

internal protocol DropInRouterProtocol: Router, AnyObject {
    var delegate: DropInRouterDelegate? { get set }
    
    func handle(action: Action)
    func present(_ viewController: UIViewController, animated: Bool)
    
    func didOpenExternalApplication(component: any ActionComponent)
    func didProvide(_ data: ActionComponentData, from component: any ActionComponent)
    func didComplete(from component: any ActionComponent)
    func didFail(with error: any Error, from component: any ActionComponent)
}

internal class DropInRouter: DropInRouterProtocol {
    
    // MARK: - Properties
    
    internal weak var delegate: DropInRouterDelegate?
    
    internal private(set) lazy var rootViewController: UIViewController = {
        resolveRootView()
    }()
    
    private let viewModel: DropInViewModelProtocol
    
    private let preselectedPaymentMethodAssembler: PreselectedPaymentMethodAssemblerProtocol
    private let paymentMethodListAssembler: PaymentMethodListAssemblerProtocol
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    
    private var preselectedPaymentMethodRouter: Router?
    private var paymentMethodListRouter: Router?
    
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
    
    // MARK: - DropInRootRouterProtocol
    
    internal func handle(action: Action) {
        viewModel.handle(action: action)
    }
    
    internal func present(_ viewController: UIViewController, animated: Bool) {
        paymentMethodListRouter?.rootViewController.present(viewController, animated: animated)
    }
    
    internal func didOpenExternalApplication(component: any ActionComponent) {
        delegate?.didOpenExternalApplication(component: component)
    }
    
    internal func didProvide(_ data: ActionComponentData, from component: any ActionComponent) {
        delegate?.didProvide(data, from: component)
    }
    
    internal func didComplete(from component: any ActionComponent) {
        delegate?.didComplete(from: component)
    }
    
    internal func didFail(with error: any Error, from component: any ActionComponent) {
        delegate?.didFail(with: error, from: component)
    }

    // MARK: - Private
    
    private func resolveRootView() -> UIViewController {
        switch viewModel.root {
        case let .preselected(paymentComponent):
            let preselectedPaymentMethodRouter = preselectedPaymentMethodAssembler.resolvePreselectedPaymentMethodRouter(
                delegate: self,
                component: paymentComponent,
                title: "Preselected PM"
            )
            self.preselectedPaymentMethodRouter = preselectedPaymentMethodRouter
            let preselectedPaymentMethodViewController = preselectedPaymentMethodRouter.rootViewController
            let navigationController = UINavigationController(rootViewController: preselectedPaymentMethodViewController)
            return navigationController
        case let .component(paymentComponent):
            // TODO: - Handle standalone component case
            //            let componentView = componentContainerAssembler.resolveContainerView(for: paymentComponent)
            //            return componentView
            return UIViewController()
        case .paymentMethodList:
            let paymentMethodListRouter = paymentMethodListAssembler.resolvePaymentMethodListRouter(delegate: self)
            self.paymentMethodListRouter = paymentMethodListRouter
            return paymentMethodListRouter.rootViewController
        }
    }
}

// MARK: - PreselectedPaymentMethodRouterDelegate

extension DropInRouter: PreselectedPaymentMethodRouterDelegate {
        
    func showAllPaymentMethods() {
        let paymentMethodListRouter = paymentMethodListAssembler.resolvePaymentMethodListRouter(delegate: self)
        self.paymentMethodListRouter = paymentMethodListRouter
        rootViewController.present(paymentMethodListRouter.rootViewController, animated: true)
    }
}

// MARK: - PaymentMethodListRouterDelegate

extension DropInRouter: PaymentMethodListRouterDelegate {
        
    func paymentMethodListDidCancel(completion: (() -> Void)?) {
        rootViewController.presentingViewController?.dismiss(animated: true)
        preselectedPaymentMethodRouter = nil
        paymentMethodListRouter = nil
    }
    
    func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent) {
        delegate?.didSubmit(data, from: component)
    }
    
    func didFail(with error: any Error, from component: any PaymentComponent) {
        delegate?.didFail(with: error, from: component)
    }
    
    func didCancel(component: any PaymentComponent) {
        delegate?.didCancel(component: component)
    }
}
