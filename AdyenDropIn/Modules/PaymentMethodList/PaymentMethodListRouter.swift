//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

// sourcery:AutoMockable
@MainActor
internal protocol PaymentMethodListRouterListener: AnyObject {
    func didDismissPaymentMethodList(completion: (() -> Void)?)
}

// sourcery:AutoMockable
@MainActor
internal protocol PaymentMethodListRouting: AnyObject {
    func present(component: PaymentComponent)
    func present(viewController: UIViewController)
    func present(actionViewController: UIViewController, onCancel: (() -> Void)?)
    func dismiss(completion: (() -> Void)?)
}

@MainActor
internal class PaymentMethodListRouter: Router, PaymentMethodListRouting {

    // MARK: - Properties

    private let viewController: UIViewController
    private weak var listener: PaymentMethodListRouterListener?
    private let navigationController: UINavigationController
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    private let storedPaymentMethodManagementAssembler: StoredPaymentMethodManagementAssemblerProtocol
    private let storedPaymentMethodManagementCapability: StoredPaymentMethodManagementCapability?
    private let storedPaymentMethodsProvider: () -> [any StoredPaymentMethod]
    private let onStoredPaymentMethodRemoved: (any StoredPaymentMethod) -> Void
    internal private(set) var childRouter: Router?
    
    // MARK: - Initializers

    internal init(
        viewController: UIViewController,
        navigationController: UINavigationController = UINavigationController(),
        listener: PaymentMethodListRouterListener?,
        componentContainerAssembler: ComponentContainerAssemblerProtocol,
        storedPaymentMethodManagementAssembler: StoredPaymentMethodManagementAssemblerProtocol,
        storedPaymentMethodManagementCapability: StoredPaymentMethodManagementCapability?,
        storedPaymentMethodsProvider: @escaping () -> [any StoredPaymentMethod],
        onStoredPaymentMethodRemoved: @escaping (any StoredPaymentMethod) -> Void
    ) {
        self.viewController = viewController
        self.navigationController = navigationController
        self.listener = listener
        self.componentContainerAssembler = componentContainerAssembler
        self.storedPaymentMethodManagementAssembler = storedPaymentMethodManagementAssembler
        self.storedPaymentMethodManagementCapability = storedPaymentMethodManagementCapability
        self.storedPaymentMethodsProvider = storedPaymentMethodsProvider
        self.onStoredPaymentMethodRemoved = onStoredPaymentMethodRemoved
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

    internal func present(viewController: UIViewController) {
        rootViewController.present(viewController, animated: true)
    }

    internal func present(
        actionViewController: UIViewController,
        onCancel: (() -> Void)?
    ) {
        let actionViewController = ActionPresentationHelper.viewController(
            for: actionViewController,
            onCancel: onCancel
        )
        rootViewController.present(actionViewController, animated: true)
    }

    // MARK: - Internal

    internal func presentStoredPaymentMethodManagement() {
        guard let storedPaymentMethodManagementCapability else {
            return
        }

        let storedPaymentMethodManagementRouter = storedPaymentMethodManagementAssembler
            .resolveStoredPaymentMethodManagementRouter(
                paymentMethods: storedPaymentMethodsProvider(),
                capability: storedPaymentMethodManagementCapability,
                listener: self
            )
        childRouter = storedPaymentMethodManagementRouter
        navigationController.pushViewController(storedPaymentMethodManagementRouter.rootViewController, animated: true)
    }

    // MARK: - Private

    private func pushComponentContainer(
        with component: PresentablePaymentComponent
    ) {
        let componentContainerViewController = componentContainerViewController(for: component)
        navigationController.pushViewController(componentContainerViewController, animated: true)
    }
    
    private func presentComponentContainer(
        with component: PresentablePaymentComponent
    ) {
        let componentContainerViewController = componentContainerViewController(for: component)
        setupCloseButton(controller: componentContainerViewController)
        let modalNavigationController = UINavigationController(rootViewController: componentContainerViewController)
        rootViewController.present(modalNavigationController, animated: true)
    }

    private func setupCloseButton(controller: UIViewController) {
        let closeButton = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTappedOnComponentContainerViewController)
        )
        controller.navigationItem.leftBarButtonItem = closeButton
    }

    @objc private func closeTappedOnComponentContainerViewController() {
        rootViewController.dismiss(animated: true)
        childRouter = nil
    }

    private func componentContainerViewController(
        for component: PresentablePaymentComponent
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

// MARK: - StoredPaymentMethodManagementListener

extension PaymentMethodListRouter: StoredPaymentMethodManagementListener {

    internal func didRemoveStoredPaymentMethod(_ paymentMethod: any StoredPaymentMethod) {
        onStoredPaymentMethodRemoved(paymentMethod)
    }

    internal func didRequestPaymentOptions() {
        navigationController.popViewController(animated: true)
        childRouter = nil
    }

    internal func didDismissStoredPaymentMethodManagement() {
        childRouter = nil
    }
}
