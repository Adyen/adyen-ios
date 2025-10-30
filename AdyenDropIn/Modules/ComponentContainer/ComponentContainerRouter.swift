//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol ComponentContainerRouterListener: AnyObject {
    func didDismiss()
}

internal protocol ComponentContainerRouting: AnyObject {
    func present(component: any PresentableComponent)
    func dismiss()
}

internal class ComponentContainerRouter: Router, ComponentContainerRouting {

    // MARK: - Properties

    internal let rootViewController: UIViewController
    private let loadable: LoadControllable
    private weak var listener: ComponentContainerRouterListener?

    // MARK: - Initializers

    internal init(
        viewController: UIViewController,
        loadable: LoadControllable,
        listener: ComponentContainerRouterListener
    ) {
        self.rootViewController = viewController
        self.loadable = loadable
        self.listener = listener
    }

    // MARK: - ComponentContainerRouting
    
    internal func present(component: any PresentableComponent) {
        rootViewController.present(component.viewController, animated: true)
    }
    
    internal func dismiss() {
        listener?.didDismiss()
    }
    
    // MARK: - Router
    
    internal func stopLoading() {
        loadable.stopLoading()
    }
}
