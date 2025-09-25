//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol ComponentContainerRouterDelegate: AnyObject {
    // MARK: - PaymentComponentDelegate

    func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent)
    func didFail(with error: any Error)
    func didCancel(component: any PaymentComponent)
    
    // MARK: - ActionComponentDelegate

    func didOpenExternalApplication(component: ActionComponent)
    func didProvide(_ data: ActionComponentData, from component: ActionComponent)
    func didComplete(from component: ActionComponent)
    func didFail(with error: Error, from component: ActionComponent)
}

internal protocol ComponentContainerRouterProtocol: AnyObject {
    func present(_ viewController: UIViewController, animated: Bool)
    
    // MARK: - PaymentComponentDelegate
    
    func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent)
    func didFail(with error: any Error)
    func didCancel(component: any PaymentComponent)
    
    // MARK: - ActionComponentDelegate
    
    func didOpenExternalApplication(component: ActionComponent)
    func didProvide(_ data: ActionComponentData, from component: ActionComponent)
    func didComplete(from component: ActionComponent)
    func didFail(with error: Error, from component: ActionComponent)
}

internal class ComponentContainerRouter: Router, ComponentContainerRouterProtocol {

    // MARK: - Properties

    internal let rootViewController: UIViewController
    private let viewModel: ComponentContainerViewModelProtocol
    private weak var delegate: ComponentContainerRouterDelegate?

    // MARK: - Initializers

    internal init(
        viewController: UIViewController,
        viewModel: ComponentContainerViewModelProtocol,
        delegate: ComponentContainerRouterDelegate
    ) {
        self.rootViewController = viewController
        self.viewModel = viewModel
        self.delegate = delegate
    }
    
    internal func handle(action: Action) {
        viewModel.handle(action: action)
    }

    // MARK: - ComponentContainerRouterProtocol
    
    internal func present(_ viewController: UIViewController, animated: Bool) {
        rootViewController.present(viewController, animated: animated)
    }
    
    internal func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent) {
        delegate?.didSubmit(data, from: component)
    }
    
    internal func didFail(with error: any Error) {
        delegate?.didFail(with: error)
    }
    
    internal func didCancel(component: any Adyen.PaymentComponent) {
        delegate?.didCancel(component: component)
    }
        
    internal func didOpenExternalApplication(component: any ActionComponent) {
        delegate?.didOpenExternalApplication(component: component)
    }
    
    internal func didProvide(_ data: Adyen.ActionComponentData, from component: any ActionComponent) {
        delegate?.didProvide(data, from: component)
    }
    
    internal func didComplete(from component: any ActionComponent) {
        delegate?.didComplete(from: component)
    }
    
    internal func didFail(with error: any Error, from component: any ActionComponent) {
        delegate?.didFail(with: error, from: component)
    }
}
