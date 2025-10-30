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
}

internal protocol PaymentMethodListRouting: AnyObject {
    func dismiss(completion: (() -> Void)?)
    func present(_ component: PresentableComponent)
}

internal class PaymentMethodListRouter: Router, PaymentMethodListRouting {

    // MARK: - Properties

    private let viewController: UIViewController
    private let loadable: LoadControllable
    private weak var listener: PaymentMethodListRouterListener?
    private let navigationController = UINavigationController()
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    private var childRouter: Router?

    // MARK: - Initializers

    internal init(
        viewController: UIViewController,
        loadable: LoadControllable,
        listener: PaymentMethodListRouterListener?,
        componentContainerAssembler: ComponentContainerAssemblerProtocol
    ) {
        self.viewController = viewController
        self.loadable = loadable
        self.listener = listener
        self.componentContainerAssembler = componentContainerAssembler
    }
    
    // MARK: - Router
    
    internal var rootViewController: UIViewController {
        navigationController.setViewControllers([viewController], animated: false)
        return navigationController
    }
    
    internal func stopLoading() {
        loadable.stopLoading()
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
    
    internal func cancel(component: any PaymentComponent) {
        stopLoading()
    }
}

// MARK: - ComponentContainerRouterListener

extension PaymentMethodListRouter: ComponentContainerRouterListener {
    
    internal func didDismiss() {
        stopLoading()
        childRouter = nil
    }
}
