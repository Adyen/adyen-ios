//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal protocol ComponentContainerRouterDelegate: AnyObject {
    func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent)
    func didFail(with error: any Error)
    func didCancel(component: any PaymentComponent)
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

    func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent) {
        delegate?.didSubmit(data, from: component)
    }
    
    func didFail(with error: any Error) {
        delegate?.didFail(with: error)
    }
    
    func didCancel(component: any Adyen.PaymentComponent) {
        delegate?.didCancel(component: component)
    }
}
