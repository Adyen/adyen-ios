//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol ComponentContainerRouterListener: AnyObject {
    func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent)
    func didFail(with error: any Error, from component: any PaymentComponent)
    func didCancel(component: any PaymentComponent)
}

internal protocol ComponentContainerRouting: AnyObject, PaymentComponentRouting {
    func present(_ viewController: UIViewController, animated: Bool)
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
    
    internal func present(_ viewController: UIViewController, animated: Bool) {
        rootViewController.present(viewController, animated: animated)
    }
    
    internal func submit(_ data: PaymentComponentData, from component: any PaymentComponent) {
        listener?.didSubmit(data, from: component)
    }
    
    internal func fail(with error: any Error, from component: any PaymentComponent) {
        listener?.didFail(with: error, from: component)
    }
    
    internal func cancel(component: any Adyen.PaymentComponent) {
        listener?.didCancel(component: component)
    }
    
    // MARK: - Router
    
    internal func stopLoading() {
        loadable.stopLoading()
    }
}
