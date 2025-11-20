//
// Copyright (c) 2025 Adyen N.V.
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
    func dismiss(completion: (() -> Void)?)
    func present(_ component: PresentableComponent, onCancel: @escaping () -> Void)
    func present(actionComponent: PresentableComponent)
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

    internal func present(_ component: PresentableComponent, onCancel: @escaping () -> Void) {
        let componentContainerRouter = componentContainerAssembler.resolveComponentContainerRouter(
            for: component,
            delegate: self,
            onCancel: onCancel
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

    internal func present(actionComponent: any PresentableComponent) {
        let actionWrapperViewController = ActionWrapperViewController(actionComponent: actionComponent)
        viewController.present(actionWrapperViewController, animated: true)
    }
}

// MARK: - ComponentContainerRouterListener

extension PaymentMethodListRouter: ComponentContainerRouterListener {
    
    internal func didDismissComponentContainer(completion: (() -> Void)?) {
        childRouter = nil
        completion?()
    }
}
