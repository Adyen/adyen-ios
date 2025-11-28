//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol ComponentContainerRouterListener: AnyObject {
    func didDismissComponentContainer(completion: (() -> Void)?)
}

internal protocol ComponentContainerRouting: AnyObject {
    func present(component: any PresentableComponent)
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
        if viewController.componentView is UIAlertController {
            return viewController.componentView
        }
        
        return viewController
    }

    // MARK: - ComponentContainerRouting
    
    internal func present(component: any PresentableComponent) {
        rootViewController.present(component.viewController, animated: true)
    }
    
    internal func dismiss(completion: (() -> Void)?) {
        rootViewController.dismiss(animated: true) { [weak self] in
            self?.listener?.didDismissComponentContainer(completion: completion)
        }
    }
}
