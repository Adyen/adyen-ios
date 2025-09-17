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

internal protocol ComponentContainerRouterProtocol {
    var rootViewController: UIViewController { get }
    func start()
}

internal class ComponentContainerRouter: ComponentContainerRouterProtocol {

    // MARK: - Properties

    private weak var delegate: ComponentContainerRouterDelegate?
    internal var view: UIViewController?

    // MARK: - Initializers

    internal init(delegate: ComponentContainerRouterDelegate) {
        self.delegate = delegate
    }

    // MARK: - ComponentContainerRouterProtocol

    internal var rootViewController: UIViewController {
        // TODO: - Handle alert view controller scenario [STORED PAYMENT METHODS]
        guard let view else { fatalError("No view was set") }
        if let alertController = view.children.first as? UIAlertController {
            return alertController
        }

        return view
    }

    internal func start() {
        // TODO: -
    }
}

extension ComponentContainerRouter: ComponentContainerViewModelDelegate {
        
    // MARK: - PaymentComponentDelegate

    func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent) {
        delegate?.didSubmit(data, from: component)
    }
    
    func didFail(with error: any Error) {
        delegate?.didFail(with: error)
    }
    
    func didCancel(component: any Adyen.PaymentComponent) {
        delegate?.didCancel(component: component)
    }
    
    // MARK: - ActionComponentDelegate
    
    func didOpenExternalApplication(component: any ActionComponent) {
        delegate?.didOpenExternalApplication(component: component)
    }
    
    func didProvide(_ data: Adyen.ActionComponentData, from component: any ActionComponent) {
        delegate?.didProvide(data, from: component)
    }
    
    func didComplete(from component: any ActionComponent) {
        delegate?.didComplete(from: component)
    }
    
    func didFail(with error: any Error, from component: any ActionComponent) {
        delegate?.didFail(with: error, from: component)
    }

}
