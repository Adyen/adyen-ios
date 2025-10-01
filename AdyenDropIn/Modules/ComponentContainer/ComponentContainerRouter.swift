//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol ComponentContainerRouterDelegate: AnyObject {
    func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent)
    func didFail(with error: any Error, from component: any PaymentComponent)
    func didCancel(component: any PaymentComponent)
}

internal protocol ComponentContainerRouterProtocol: AnyObject {
    func present(_ viewController: UIViewController, animated: Bool)
    func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent)
    func didFail(with error: any Error, from component: any PaymentComponent)
    func didCancel(component: any PaymentComponent)
}

internal class ComponentContainerRouter: Router, ComponentContainerRouterProtocol {

    // MARK: - Properties

    internal let rootViewController: UIViewController
    private let viewModel: RoutableComponentContainerViewModel
    private weak var delegate: ComponentContainerRouterDelegate?

    // MARK: - Initializers

    internal init(
        viewController: UIViewController,
        viewModel: RoutableComponentContainerViewModel,
        delegate: ComponentContainerRouterDelegate
    ) {
        self.rootViewController = viewController
        self.viewModel = viewModel
        self.delegate = delegate
    }

    // MARK: - ComponentContainerRouterProtocol
    
    internal func present(_ viewController: UIViewController, animated: Bool) {
        rootViewController.present(viewController, animated: animated)
    }
    
    internal func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent) {
        delegate?.didSubmit(data, from: component)
    }
    
    internal func didFail(with error: any Error, from component: any PaymentComponent) {
        delegate?.didFail(with: error, from: component)
    }
    
    internal func didCancel(component: any Adyen.PaymentComponent) {
        delegate?.didCancel(component: component)
    }
    
    // MARK: - Router
    
    internal func stopLoading() {
        viewModel.stopLoading()
    }
}
