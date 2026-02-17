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
    func present(component: PaymentComponent, onCancel: @escaping () -> Void)
    func present(actionComponent: any PresentableComponent, onCancel: (() -> Void)?)
    func dismiss(completion: (() -> Void)?)
}

internal class PaymentMethodListRouter: Router, PaymentMethodListRouting {

    // MARK: - Properties

    private let viewController: UIViewController
    private weak var listener: PaymentMethodListRouterListener?
    private let navigationController = UINavigationController()
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    internal private(set) var childRouter: Router?
    
    // MARK: - Initializers

    internal init(
        viewController: UIViewController,
        listener: PaymentMethodListRouterListener?,
        componentContainerAssembler: ComponentContainerAssemblerProtocol
    ) {
        self.viewController = viewController
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

    internal func present(
        component: PaymentComponent,
        onCancel: @escaping () -> Void
    ) {

        switch component.presentationStyle {
        case let .presentable(presentableComponent):
            switch presentableComponent.presentationConfiguration.paymentMethodList {
            case .modal, .supportPushAndModal:
                presentModalComponent(presentableComponent, onCancel: onCancel)
            case .push:
                pushComponent(presentableComponent, onCancel: onCancel)
            }
        case .notPresentable:
            break
        }
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

    private func pushComponent(
        _ component: PresentableComponent,
        onCancel: @escaping () -> Void
    ) {
        let componentContainerViewController = componentContainerViewController(for: component, onCancel: onCancel)
        viewController.navigationController?.pushViewController(componentContainerViewController, animated: true)
    }
    
    private func presentModalComponent(
        _ component: PresentableComponent,
        onCancel: @escaping () -> Void
    ) {
        let componentContainerViewController = componentContainerViewController(for: component, onCancel: onCancel)
        viewController.present(componentContainerViewController, animated: true)
    }

    private func componentContainerViewController(
        for component: PresentableComponent,
        onCancel: @escaping () -> Void
    ) -> UIViewController {
        let componentContainerRouter = componentContainerAssembler.resolveComponentContainerRouter(
            for: component,
            delegate: self,
            onCancel: onCancel
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
