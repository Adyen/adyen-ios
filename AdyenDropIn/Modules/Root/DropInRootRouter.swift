//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation
import UIKit

internal protocol Router: AnyObject {
    var rootViewController: UIViewController { get }
    func start()
}

internal protocol DropInRootRouterProtocol: Router {
    func start()
    var rootViewController: UIViewController { get }
}

internal class DropInRootRouter: DropInRootRouterProtocol {

    private enum DropInRoot {
        case preselected(_ paymentComponent: PaymentComponent)
        case component(_ paymentComponent: PresentableComponent)
        case paymentMethodList
    }

    // MARK: - Properties

    private let preselectedPaymentMethodAssembler: PreselectedPaymentMethodAssemblerProtocol
    private let paymentMethodListAssembler: PaymentMethodListAssemblerProtocol
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    private let componentManager: ComponentManager
    private let configuration: DropInComponent.Configuration

    private let navigationController: DropInRootViewController

    private var preselectedPaymentMethodRouter: PreselectedPaymentMethodRouterProtocol?
    private var paymentMethodListRouter: PaymentMethodListRouterProtocol?

    // MARK: - Initializers

    internal init(
        preselectedPaymentMethodAssembler: PreselectedPaymentMethodAssemblerProtocol,
        paymentMethodListAssembler: PaymentMethodListAssemblerProtocol,
        componentContainerAssembler: ComponentContainerAssemblerProtocol,
        componentManager: ComponentManager,
        configuration: DropInComponent.Configuration
    ) {
        self.preselectedPaymentMethodAssembler = preselectedPaymentMethodAssembler
        self.paymentMethodListAssembler = paymentMethodListAssembler
        self.componentContainerAssembler = componentContainerAssembler
        self.componentManager = componentManager
        self.configuration = configuration
        self.navigationController = DropInRootViewController()
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
        switch root {
        case let .preselected(paymentComponent):
            let preselectedPaymentMethodRouter = preselectedPaymentMethodAssembler.resolvePreselectedPaymentMethodRouter(
                component: paymentComponent,
                title: "Preselected PM"
            )
            preselectedPaymentMethodRouter.delegate = self
            self.preselectedPaymentMethodRouter = preselectedPaymentMethodRouter
            return preselectedPaymentMethodRouter.rootViewController
        case let .component(paymentComponent):
            let componentView = componentContainerAssembler.resolveContainerView(for: paymentComponent)
            return componentView
        case .paymentMethodList:
            let paymentMethodListRouter = paymentMethodListAssembler.resolvePaymentMethodListRouter()
            paymentMethodListRouter.delegate = self
            self.paymentMethodListRouter = paymentMethodListRouter
            return paymentMethodListRouter.rootViewController
        }
    }

    private var root: DropInRoot {
        if configuration.allowPreselectedPaymentView, let storedPaymentMethod = componentManager.storedComponents.first {
            return .preselected(storedPaymentMethod)
        } else if configuration.allowsSkippingPaymentList, let paymentComponent = componentManager.singleRegularComponent {
            return .component(paymentComponent)
        } else {
            return .paymentMethodList
        }
    }
}

extension DropInRootRouter: PreselectedPaymentMethodRouterDelegate {

    func showAllPaymentMethods() {
        let paymentMethodListRouter = paymentMethodListAssembler.resolvePaymentMethodListRouter()
        self.paymentMethodListRouter = paymentMethodListRouter
        paymentMethodListRouter.delegate = self
        paymentMethodListRouter.start()
        
        navigationController.present(paymentMethodListRouter.rootViewController, animated: true)
    }

    func didProceed(with paymentComponent: any PresentableComponent) {
        let componentViewController = componentContainerAssembler.resolveContainerView(for: paymentComponent)
        navigationController.present(componentViewController, animated: true)
    }
}

extension DropInRootRouter: PaymentMethodListRouterDelegate {

    func cancelPayment(completion: (() -> Void)?) {
        navigationController.presentingViewController?.dismiss(animated: true)
        preselectedPaymentMethodRouter = nil
        paymentMethodListRouter = nil
    }
}
