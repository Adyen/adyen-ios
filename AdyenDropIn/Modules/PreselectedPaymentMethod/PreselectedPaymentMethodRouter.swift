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

#if canImport(AdyenUI)
    import AdyenUI
#endif

// sourcery:AutoMockable
@MainActor
internal protocol PreselectedPaymentMethodRouterListener: AnyObject {
    func didDismissPreselectedPaymentMethod(completion: (() -> Void)?)
}

// sourcery:AutoMockable
@MainActor
internal protocol PreselectedPaymentMethodRouting: Router {
    func presentPaymentMethodList()
    func present(component: PaymentComponent)
    func dismiss(completion: (() -> Void)?)
}

@MainActor
internal class PreselectedPaymentMethodRouter: PreselectedPaymentMethodRouting {
    private enum Constants {
        static let chevronBackwardImage = "chevron.backward"
    }

    // MARK: - Properties

    internal let rootViewController: UIViewController
    private weak var listener: PreselectedPaymentMethodRouterListener?
    private let paymentMethodListAssembler: PaymentMethodListAssemblerProtocol
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    private let storedPaymentMethodContentAssembler: StoredPaymentMethodContentAssembling
    private let theme: CheckoutTheme
    internal private(set) var childRouter: Router?
    
    // MARK: - Initializers
    
    internal init(
        viewController: UIViewController,
        listener: PreselectedPaymentMethodRouterListener?,
        paymentMethodListAssembler: PaymentMethodListAssemblerProtocol,
        componentContainerAssembler: ComponentContainerAssemblerProtocol,
        storedPaymentMethodContentAssembler: StoredPaymentMethodContentAssembling,
        theme: CheckoutTheme
    ) {
        self.rootViewController = viewController
        self.listener = listener
        self.paymentMethodListAssembler = paymentMethodListAssembler
        self.componentContainerAssembler = componentContainerAssembler
        self.storedPaymentMethodContentAssembler = storedPaymentMethodContentAssembler
        self.theme = theme
    }

    // MARK: - PreselectedPaymentMethodRouting

    internal func presentPaymentMethodList() {
        let paymentMethodListRouter = paymentMethodListAssembler.resolvePaymentMethodListRouter(listener: self)
        self.childRouter = paymentMethodListRouter
        let navigationController = CheckoutNavigationController(
            rootViewController: paymentMethodListRouter.rootViewController,
            theme: theme
        )
        rootViewController.present(navigationController, animated: true)
    }

    internal func present(
        component: PaymentComponent
    ) {
        switch component.type {
        case .stored:
            presentModalStoredPaymentMethodContent(component)
        case .regular:
            presentModalComponent(component)
        case .generic:
            break
        }
    }

    internal func dismiss(completion: (() -> Void)?) {
        rootViewController.dismiss(animated: true) { [weak self] in
            self?.childRouter = nil
            self?.listener?.didDismissPreselectedPaymentMethod(completion: completion)
        }
    }

    // MARK: - Private

    private func presentModalStoredPaymentMethodContent(
        _ component: PaymentComponent
    ) {
        guard let router = storedPaymentMethodContentAssembler.resolveStoredPaymentMethodContentRouter(
            for: component,
            listener: self
        ) else {
            // No dedicated stored payment content exists for this component; fall back to the generic component presentation.
            return presentModalComponent(component)
        }
        childRouter = router
        let navigationController = CheckoutNavigationController(
            rootViewController: router.rootViewController,
            theme: theme
        )
        navigationController.isModalInPresentation = true
        rootViewController.present(navigationController, animated: true)
    }

    private func presentModalComponent(
        _ component: PaymentComponent
    ) {
        let componentContainerViewController = componentContainerViewController(for: component)

        let navigationController = CheckoutNavigationController(
            rootViewController: componentContainerViewController,
            theme: theme
        )
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
        for component: PaymentComponent
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
    
    /// Closing the payment method list closes the drop in it was opened from,
    /// as the shopper asked to leave the flow rather than to go back.
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

extension PreselectedPaymentMethodRouter: StoredPaymentMethodContentRouterListener {

    internal func dismissStoredPaymentMethodContent() {
        rootViewController.dismiss(animated: true)
        childRouter = nil
    }
}
