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
}

internal protocol Router: AnyObject {
    var rootViewController: UIViewController { get }
    func start()
}

internal protocol DropInRouterProtocol: Router {
    var delegate: DropInRouterDelegate? { get set }
    var rootViewController: UIViewController { get }
    func start()
}

internal class DropInRouter: DropInRouterProtocol {

    // MARK: - Properties

    internal weak var delegate: DropInRouterDelegate?
    private let navigationController: DropInNavigationController
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
        self.navigationController = DropInNavigationController()
    }

    // MARK: - DropInRootRouterProtocol

    internal func start() {
        let rootView = resolveRootView()
        navigationController.setViewControllers([rootView], animated: false)
    }

    internal var rootViewController: UIViewController {
        navigationController
    }

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
            return preselectedPaymentMethodRouter.rootViewController
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
        paymentMethodListRouter.start()
        
        navigationController.present(paymentMethodListRouter.rootViewController, animated: true)
    }
}

extension DropInRouter: PaymentMethodListRouterDelegate {

    // MARK: - PaymentMethodListRouterDelegate

    func paymentMethodListDidCancel(completion: (() -> Void)?) {
        navigationController.presentingViewController?.dismiss(animated: true)
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
}
