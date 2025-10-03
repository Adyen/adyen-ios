//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol PaymentMethodListRouterListener: AnyObject {
    func didDismiss(completion: (() -> Void)?)
    func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent)
    func didFail(with error: any Error, from component: any PaymentComponent)
    func didCancel(component: any PaymentComponent)
}

internal protocol PaymentMethodListRouting: AnyObject, PaymentComponentRouting {
    func dismiss(completion: (() -> Void)?)
    func present(_ component: PresentableComponent)
}

internal class PaymentMethodListRouter: Router, PaymentMethodListRouting {

    // MARK: - Properties

    private let viewController: UIViewController
    private let viewModel: RoutablePaymentMethodListViewModel
    private weak var listener: PaymentMethodListRouterListener?
    private let navigationController = UINavigationController()
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    private var childRouter: Router?

    // MARK: - Initializers

    internal init(
        viewController: UIViewController,
        viewModel: RoutablePaymentMethodListViewModel,
        listener: PaymentMethodListRouterListener?,
        componentContainerAssembler: ComponentContainerAssemblerProtocol
    ) {
        self.viewController = viewController
        self.viewModel = viewModel
        self.listener = listener
        self.componentContainerAssembler = componentContainerAssembler
    }
    
    // MARK: - Router
    
    internal var rootViewController: UIViewController {
        navigationController.setViewControllers([viewController], animated: false)
        return navigationController
    }
    
    internal func stopLoading() {
        viewModel.stopLoading()
    }

    // MARK: - PaymentMethodListRouting

    internal func dismiss(completion: (() -> Void)?) {
        listener?.didDismiss(completion: completion)
        childRouter = nil
    }

    internal func present(_ component: PresentableComponent) {
        let componentContainerRouter = componentContainerAssembler.resolveComponentContainerRouter(
            for: component,
            delegate: self
        )
        self.childRouter = componentContainerRouter

        let componentContainerViewController = componentContainerRouter.rootViewController

        // TODO: - Invert `requiresModalPresentation` logic or remove it fully.
        if component.requiresModalPresentation {
            viewController.navigationController?.pushViewController(componentContainerViewController, animated: true)
        } else {
            viewController.present(componentContainerViewController, animated: true)
        }
    }
    
    internal func submit(_ data: PaymentComponentData, from component: any PaymentComponent) {
        listener?.didSubmit(data, from: component)
    }
    
    internal func fail(with error: any Error, from component: any PaymentComponent) {
        listener?.didFail(with: error, from: component)
    }
    
    internal func cancel(component: any PaymentComponent) {
        viewModel.stopLoading()
        listener?.didCancel(component: component)
    }
}

// MARK: - ComponentContainerRouterListener

extension PaymentMethodListRouter: ComponentContainerRouterListener {
    
    func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent) {
        listener?.didSubmit(data, from: component)
    }
    
    func didFail(with error: any Error, from component: any Adyen.PaymentComponent) {
        listener?.didFail(with: error, from: component)
    }
    
    func didCancel(component: any Adyen.PaymentComponent) {
        viewModel.stopLoading()
        listener?.didCancel(component: component)
    }
}
