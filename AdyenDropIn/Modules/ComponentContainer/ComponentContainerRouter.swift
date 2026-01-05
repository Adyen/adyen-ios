//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

// sourcery:AutoMockable
internal protocol ComponentContainerRouterListener: AnyObject {
    func didDismissComponentContainer(completion: (() -> Void)?)
}

// sourcery:AutoMockable
internal protocol ComponentContainerRouting: AnyObject {
    func present(paymentComponent: PresentableComponent)
    func present(actionComponent: PresentableComponent, onCancel: (() -> Void)?)
    func dismiss(completion: (() -> Void)?)
}

internal class ComponentContainerRouter: Router, ComponentContainerRouting {

    // MARK: - Properties

    private let viewController: ComponentContainerViewController
    private weak var listener: ComponentContainerRouterListener?
    internal private(set) var childRouter: Router?

    // MARK: - Initializers

    internal init(
        viewController: ComponentContainerViewController,
        listener: ComponentContainerRouterListener
    ) {
        self.viewController = viewController
        self.listener = listener
    }
    
    // MARK: - Router
    
    internal var rootViewController: UIViewController {
        if viewController.componentViewController is UIAlertController {
            return viewController.componentViewController
        }
        
        return viewController
    }

    // MARK: - ComponentContainerRouting
    
    internal func present(paymentComponent: any PresentableComponent) {
        let componentViewController = paymentComponent.viewController
        rootViewController.navigationController?.pushViewController(componentViewController, animated: true)
    }

    internal func present(actionComponent: any PresentableComponent, onCancel: (() -> Void)?) {
        let actionViewController = ActionPresentationHelper.viewController(
            for: actionComponent,
            onCancel: onCancel
        )
        rootViewController.present(actionViewController, animated: true)
    }

    internal func dismiss(completion: (() -> Void)?) {
        rootViewController.dismiss(animated: true) { [weak self] in
            self?.listener?.didDismissComponentContainer(completion: completion)
        }
    }
}
