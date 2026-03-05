//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

// sourcery:AutoMockable
internal protocol PaymentMethodListRouterListener: AnyObject {
    func didDismissPaymentMethodList(completion: (() -> Void)?)
}

// sourcery:AutoMockable
internal protocol PaymentMethodListRouting: AnyObject {
    func present(component: PaymentComponent)
    func present(applePayComponent: PresentableComponent)
    func present(actionComponent: any PresentableComponent, onCancel: (() -> Void)?)
    func dismiss(completion: (() -> Void)?)
}

internal class PaymentMethodListRouter: Router, PaymentMethodListRouting {

    // MARK: - Properties

    private let viewController: UIViewController
    private weak var listener: PaymentMethodListRouterListener?
    private let navigationController: UINavigationController
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    internal private(set) var childRouter: Router?
    
    // MARK: - Initializers

    internal init(
        viewController: UIViewController,
        navigationController: UINavigationController = UINavigationController(),
        listener: PaymentMethodListRouterListener?,
        componentContainerAssembler: ComponentContainerAssemblerProtocol
    ) {
        self.viewController = viewController
        self.navigationController = navigationController
        self.listener = listener
        self.componentContainerAssembler = componentContainerAssembler
    }
    
    // MARK: - Router
    
    internal var rootViewController: UIViewController {
        navigationController.setViewControllers([viewController], animated: false)
        return navigationController
    }

    // MARK: - PaymentMethodListRouting

    internal func dismiss(completion: (() -> Void)?) {
        childRouter = nil
        listener?.didDismissPaymentMethodList(completion: completion)
    }

    internal func present(component: PaymentComponent) {
        switch component.type {
        case let .regular(regularComponent):
            pushComponentContainer(with: regularComponent)
        case let .stored(storedComponent):
            presentComponentContainer(with: storedComponent)
        case .initiable:
            break
        }
    }

    internal func present(applePayComponent: PresentableComponent) {
        viewController.present(applePayComponent.viewController, animated: true)
    }

    internal func present(
        actionComponent: any PresentableComponent,
        onCancel: (() -> Void)?
    ) {
        let actionViewController = ActionPresentationHelper.viewController(
            for: actionComponent,
            onCancel: onCancel
        )
        viewController.present(actionViewController, animated: true)
    }

    // MARK: - Private

    private func pushComponentContainer(
        with component: PresentableComponent
    ) {
        let componentContainerViewController = componentContainerViewController(for: component)
        navigationController.pushViewController(componentContainerViewController, animated: true)
    }
    
    private func presentComponentContainer(
        with component: PresentableComponent
    ) {
        let componentContainerViewController = componentContainerViewController(for: component)
        viewController.present(componentContainerViewController, animated: true)
    }

    private func componentContainerViewController(
        for component: PresentableComponent
    ) -> UIViewController {
        let componentContainerRouter = componentContainerAssembler.resolveComponentContainerRouter(
            for: component,
            listener: self
        )
        childRouter = componentContainerRouter
        return componentContainerRouter.rootViewController
    }
}

// MARK: - ComponentContainerRouterListener

extension PaymentMethodListRouter: ComponentContainerRouterListener {
    
    internal func didDismissComponentContainer(completion: (() -> Void)?) {
        childRouter = nil
        completion?()
    }
}
