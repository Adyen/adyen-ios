//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

@MainActor
internal protocol PreselectedPaymentMethodRouterListener: AnyObject {
    func didDismissPreselectedPaymentMethod(completion: (() -> Void)?)
}

// sourcery:AutoMockable
@MainActor
internal protocol PreselectedPaymentMethodRouting: AnyObject {
    func presentPaymentMethodList()
    func present(component: PaymentComponent)
    func present(actionComponent: any PresentableComponent, onCancel: (() -> Void)?)
    func dismiss(completion: (() -> Void)?)
}

@MainActor
internal class PreselectedPaymentMethodRouter: Router, PreselectedPaymentMethodRouting {
    private enum Constants {
        static let chevronBackwardImage = "chevron.backward"
    }

    // MARK: - Properties

    internal let rootViewController: UIViewController
    private weak var listener: PreselectedPaymentMethodRouterListener?
    private let paymentMethodListAssembler: PaymentMethodListAssemblerProtocol
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    internal private(set) var childRouter: Router?
    
    // MARK: - Initializers
    
    internal init(
        viewController: UIViewController,
        listener: PreselectedPaymentMethodRouterListener?,
        paymentMethodListAssembler: PaymentMethodListAssemblerProtocol,
        componentContainerAssembler: ComponentContainerAssemblerProtocol
    ) {
        self.rootViewController = viewController
        self.listener = listener
        self.paymentMethodListAssembler = paymentMethodListAssembler
        self.componentContainerAssembler = componentContainerAssembler
    }

    // MARK: - PreselectedPaymentMethodRouting

    internal func presentPaymentMethodList() {
        let paymentMethodListRouter = paymentMethodListAssembler.resolvePaymentMethodListRouter(delegate: self)
        self.childRouter = paymentMethodListRouter
        rootViewController.present(paymentMethodListRouter.rootViewController, animated: true)
    }

    internal func present(
        paymentComponent: any PresentableComponent
    ) {
        let componentContainerRouter = componentContainerAssembler.resolveComponentContainerRouter(
            for: paymentComponent,
            listener: self
        )
        self.childRouter = componentContainerRouter
        rootViewController.present(componentContainerRouter.rootViewController, animated: true)
    }

    internal func present(
        component: PaymentComponent
    ) {
        switch component.type {
        case let .regular(regularComponent):
            presentModalComponent(regularComponent)
        case let .stored(storedComponent):
            presentModalComponent(storedComponent)
        case .initiable:
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
        rootViewController.present(actionViewController, animated: true)
    }

    internal func dismiss(completion: (() -> Void)?) {
        rootViewController.dismiss(animated: true) { [weak self] in
            self?.childRouter = nil
            self?.listener?.didDismissPreselectedPaymentMethod(completion: completion)
        }
    }

    // MARK: - Private

    private func presentModalComponent(
        _ component: PresentableComponent
    ) {
        let componentContainerViewController = componentContainerViewController(for: component)

        let navigationController = UINavigationController(rootViewController: componentContainerViewController)
        setupNavigationBackButton(controller: componentContainerViewController)
        rootViewController.present(navigationController, animated: true)
    }

    private func setupNavigationBackButton(controller: UIViewController) {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: Constants.chevronBackwardImage),
            style: .plain,
            target: self,
            action: #selector(backTappedOnComponentContainerViewController)
        )

        controller.navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backTappedOnComponentContainerViewController() {
        rootViewController.dismiss(animated: true)
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

// MARK: - PaymentMethodListRouterListener

extension PreselectedPaymentMethodRouter: PaymentMethodListRouterListener {
    
    internal func didDismissPaymentMethodList(completion: (() -> Void)?) {
        rootViewController.presentingViewController?.dismiss(animated: true) { [weak self] in
            self?.childRouter = nil
            self?.listener?.didDismissPreselectedPaymentMethod(completion: completion)
        }
    }
}

// MARK: - ComponentContainerRouterListener

extension PreselectedPaymentMethodRouter: ComponentContainerRouterListener {
    
    internal func didDismissComponentContainer(completion: (() -> Void)?) {
        childRouter = nil
        completion?()
    }
}
