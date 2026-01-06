//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol PaymentMethodListRouterListener: AnyObject {
    func didDismissPaymentMethodList(completion: (() -> Void)?)
}

internal protocol PaymentMethodListRouting: AnyObject {
    func present(paymentComponent: PresentableComponent, onCancel: @escaping () -> Void)
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

    internal func present(paymentComponent: PresentableComponent, onCancel: @escaping () -> Void) {
        let componentContainerRouter = componentContainerAssembler.resolveComponentContainerRouter(
            for: paymentComponent,
            delegate: self,
            onCancel: onCancel
        )
        self.childRouter = componentContainerRouter

        let componentContainerViewController = componentContainerRouter.rootViewController

        // TODO: - Invert `requiresModalPresentation` logic or remove it fully.
        if paymentComponent.requiresModalPresentation {
            viewController.navigationController?.pushViewController(componentContainerViewController, animated: true)
        } else {
            viewController.present(componentContainerViewController, animated: true)
        }
    }

    internal func present(actionComponent: any PresentableComponent, onCancel: (() -> Void)?) {
        let actionViewController = ActionPresentationHelper.viewController(
            for: actionComponent,
            onCancel: onCancel
        )
        viewController.present(actionViewController, animated: true)
    }
}

// MARK: - ComponentContainerRouterListener

extension PaymentMethodListRouter: ComponentContainerRouterListener {
    
    internal func didDismissComponentContainer(completion: (() -> Void)?) {
        childRouter = nil
        completion?()
    }
}
