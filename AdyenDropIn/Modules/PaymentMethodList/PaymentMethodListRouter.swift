//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenActions)
    import AdyenActions
#endif
import Foundation
import UIKit

// sourcery:AutoMockable
@MainActor
internal protocol PaymentMethodListRouterListener: AnyObject {
    func didDismissPaymentMethodList(completion: (() -> Void)?)
}

// sourcery:AutoMockable
@MainActor
internal protocol PaymentMethodListRouting: Router {
    func present(component: PaymentComponent)
    func present(viewController: UIViewController)
    func presentStoredPaymentMethodManagement()
    func dismiss(completion: (() -> Void)?)
}

@MainActor
internal class PaymentMethodListRouter: PaymentMethodListRouting {

    // MARK: - Properties

    private let viewController: UIViewController
    private weak var listener: PaymentMethodListRouterListener?
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    private let genericPaymentMethodAssembler: GenericPaymentMethodAssemblerProtocol
    private let storedPaymentMethodManagementAssembler: StoredPaymentMethodManagementAssemblerProtocol
    private let storedPaymentMethodManagementCapability: StoredPaymentMethodManagementCapability?
    private let storedPaymentMethodsProvider: () -> [any StoredPaymentMethod]
    private let onStoredPaymentMethodRemoved: (any StoredPaymentMethod) -> Void
    internal var childRouter: Router?
    
    // MARK: - Initializers

    internal init(
        viewController: UIViewController,
        listener: PaymentMethodListRouterListener?,
        componentContainerAssembler: ComponentContainerAssemblerProtocol,
        genericPaymentMethodAssembler: GenericPaymentMethodAssemblerProtocol,
        storedPaymentMethodManagementAssembler: StoredPaymentMethodManagementAssemblerProtocol,
        storedPaymentMethodManagementCapability: StoredPaymentMethodManagementCapability?,
        storedPaymentMethodsProvider: @escaping () -> [any StoredPaymentMethod],
        onStoredPaymentMethodRemoved: @escaping (any StoredPaymentMethod) -> Void
    ) {
        self.viewController = viewController
        self.listener = listener
        self.componentContainerAssembler = componentContainerAssembler
        self.genericPaymentMethodAssembler = genericPaymentMethodAssembler
        self.storedPaymentMethodManagementAssembler = storedPaymentMethodManagementAssembler
        self.storedPaymentMethodManagementCapability = storedPaymentMethodManagementCapability
        self.storedPaymentMethodsProvider = storedPaymentMethodsProvider
        self.onStoredPaymentMethodRemoved = onStoredPaymentMethodRemoved
    }
    
    // MARK: - Router
    
    internal private(set) lazy var rootViewController: UIViewController = {
        viewController
    }()

    // MARK: - PaymentMethodListRouting

    internal func dismiss(completion: (() -> Void)?) {
        childRouter = nil
        listener?.didDismissPaymentMethodList(completion: completion)
    }

    internal func present(component: PaymentComponent) {
        switch component.type {
        case .regular, .stored:
            pushComponentContainer(with: component)
        case .generic:
            pushGenericPaymentMethod(with: component)
        }
    }

    internal func present(viewController: UIViewController) {
        rootViewController.present(viewController, animated: true)
    }

    // MARK: - Internal

    internal func presentStoredPaymentMethodManagement() {
        guard childRouter == nil else {
            return
        }

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
        viewController.navigationController?.pushViewController(storedPaymentMethodManagementRouter.rootViewController, animated: true)
    }

    // MARK: - Private

    private func pushComponentContainer(
        with component: PaymentComponent
    ) {
        let componentContainerViewController = componentContainerViewController(for: component)
        viewController.navigationController?.pushViewController(componentContainerViewController, animated: true)
    }

    private func pushGenericPaymentMethod(
        with component: PaymentComponent
    ) {
        let genericPaymentMethodViewController = genericPaymentMethodViewController(for: component)
        viewController.navigationController?.pushViewController(genericPaymentMethodViewController, animated: true)
    }

    private func componentContainerViewController(
        for component: PaymentComponent
    ) -> UIViewController {
        let componentContainerRouter = componentContainerAssembler.resolveComponentContainerRouter(
            for: component,
            listener: self
        )
        childRouter = componentContainerRouter
        return componentContainerRouter.rootViewController
    }

    private func genericPaymentMethodViewController(
        for component: PaymentComponent
    ) -> UIViewController {
        let genericPaymentMethodRouter = genericPaymentMethodAssembler.resolveGenericPaymentMethodRouter(
            for: component,
            listener: self
        )
        childRouter = genericPaymentMethodRouter
        return genericPaymentMethodRouter.rootViewController
    }
}

// MARK: - ComponentContainerRouterListener

extension PaymentMethodListRouter: ComponentContainerRouterListener {
    
    internal func didDismissComponentContainer(completion: (() -> Void)?) {
        childRouter = nil
        completion?()
    }
}

// MARK: - GenericPaymentMethodRouterListener

extension PaymentMethodListRouter: GenericPaymentMethodRouterListener {

    internal func didDismissGenericPaymentMethod() {
        childRouter = nil
    }
}

// MARK: - StoredPaymentMethodManagementListener

extension PaymentMethodListRouter: StoredPaymentMethodManagementListener {

    internal func didRemoveStoredPaymentMethod(_ paymentMethod: any StoredPaymentMethod) {
        onStoredPaymentMethodRemoved(paymentMethod)
    }

    internal func didRequestPaymentOptions() {
        viewController.navigationController?.popViewController(animated: true)
        childRouter = nil
    }

    internal func didDismissStoredPaymentMethodManagement() {
        childRouter = nil
    }
}
