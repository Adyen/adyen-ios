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
    func didFail(with error: any Error)
    func didCancel(component: any PaymentComponent)
    
    func didOpenExternalApplication(component: ActionComponent)
    func didProvide(_ data: ActionComponentData, from component: ActionComponent)
    func didComplete(from component: ActionComponent)
    func didFail(with error: Error, from component: ActionComponent)
}

internal protocol Router: AnyObject {
    var rootViewController: UIViewController { get }
}

internal protocol DropInRouterProtocol: Router {
    var delegate: DropInRouterDelegate? { get set }
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

    private var preselectedPaymentMethodRouter: PreselectedPaymentMethodRouterProtocol?
    private var paymentMethodListRouter: PaymentMethodListRouterProtocol?

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

    // MARK: - Private

    private func resolveRootView() -> UIViewController {
        switch viewModel.root {
        case let .preselected(paymentComponent):
            let preselectedPaymentMethodRouter = preselectedPaymentMethodAssembler.resolvePreselectedPaymentMethodRouter(
                component: paymentComponent,
                title: "Preselected PM"
            )
            preselectedPaymentMethodRouter.delegate = self
            self.preselectedPaymentMethodRouter = preselectedPaymentMethodRouter
            let preselectedPaymentMethodViewController = preselectedPaymentMethodRouter.rootViewController
            let navigationController = DropInNavigationController(rootViewController: preselectedPaymentMethodViewController)
            return navigationController
        case let .component(paymentComponent):
            // TODO: - Handle standalone component case
//            let componentView = componentContainerAssembler.resolveContainerView(for: paymentComponent)
//            return componentView
            return UIViewController()
        case .paymentMethodList:
            let paymentMethodListRouter = paymentMethodListAssembler.resolvePaymentMethodListRouter()
            paymentMethodListRouter.delegate = self
            self.paymentMethodListRouter = paymentMethodListRouter
            return paymentMethodListRouter.rootViewController
        }
    }
}

extension DropInRouter: PreselectedPaymentMethodRouterDelegate {

    // MARK: - PreselectedPaymentMethodRouterDelegate

    func showAllPaymentMethods() {
        let paymentMethodListRouter = paymentMethodListAssembler.resolvePaymentMethodListRouter()
        self.paymentMethodListRouter = paymentMethodListRouter
        paymentMethodListRouter.delegate = self
        
        rootViewController.present(paymentMethodListRouter.rootViewController, animated: true)
    }
}

extension DropInRouter: PaymentMethodListRouterDelegate {

    // MARK: - PaymentComponentDelegate

    func paymentMethodListDidCancel(completion: (() -> Void)?) {
        rootViewController.presentingViewController?.dismiss(animated: true)
        preselectedPaymentMethodRouter = nil
        paymentMethodListRouter = nil
    }

    func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent) {
        delegate?.didSubmit(data, from: component)
    }

    func didFail(with error: any Error) {
        delegate?.didFail(with: error)
    }

    func didCancel(component: any PaymentComponent) {
        delegate?.didCancel(component: component)
    }
    
    // MARK: - ActionComponentDelegate
    
    func didOpenExternalApplication(component: any ActionComponent) {
        delegate?.didOpenExternalApplication(component: component)
    }
    
    func didProvide(_ data: ActionComponentData, from component: any ActionComponent) {
        delegate?.didProvide(data, from: component)
    }
    
    func didComplete(from component: any ActionComponent) {
        delegate?.didComplete(from: component)
    }
    
    func didFail(with error: any Error, from component: any ActionComponent) {
        delegate?.didFail(with: error, from: component)
    }
}
