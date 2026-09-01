//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

@MainActor
internal protocol StoredPaymentComponentRouterListener: AnyObject {
    func didDismissStoredPaymentComponent(completion: (() -> Void)?)
}

// sourcery:AutoMockable
@MainActor
internal protocol StoredPaymentComponentRouting: AnyObject {
    func present(paymentComponent: PresentablePaymentComponent)
    func present(actionViewController: UIViewController, onCancel: (() -> Void)?)
    func dismiss(completion: (() -> Void)?)
}

@MainActor
internal class StoredPaymentComponentRouter: Router, StoredPaymentComponentRouting {

    // MARK: - Properties

    internal let rootViewController: UIViewController
    private weak var listener: StoredPaymentComponentRouterListener?
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    internal private(set) var childRouter: Router?

    // MARK: - Initializers

    internal init(
        viewController: UIViewController,
        listener: StoredPaymentComponentRouterListener?,
        componentContainerAssembler: ComponentContainerAssemblerProtocol
    ) {
        self.rootViewController = viewController
        self.listener = listener
        self.componentContainerAssembler = componentContainerAssembler
    }

    // MARK: - StoredPaymentComponentRouting

    internal func present(paymentComponent: PresentablePaymentComponent) {
        let componentContainerRouter = componentContainerAssembler.resolveComponentContainerRouter(
            for: paymentComponent,
            listener: self
        )
        self.childRouter = componentContainerRouter

        let componentContainerViewController = componentContainerRouter.rootViewController
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

    internal func dismiss(completion: (() -> Void)?) {
        if rootViewController.presentingViewController != nil {
            rootViewController.dismiss(animated: true) { [weak self] in
                self?.childRouter = nil
                self?.listener?.didDismissStoredPaymentComponent(completion: completion)
            }
        } else {
            rootViewController.navigationController?.popViewController(animated: true)
            childRouter = nil
            listener?.didDismissStoredPaymentComponent(completion: completion)
        }
    }
}

// MARK: - ComponentContainerRouterListener

extension StoredPaymentComponentRouter: ComponentContainerRouterListener {

    internal func didDismissComponentContainer(completion: (() -> Void)?) {
        childRouter = nil
        completion?()
    }
}
