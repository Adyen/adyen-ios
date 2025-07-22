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
    var delegate: ComponentContainerRouterDelegate? { get set }
    var rootViewController: UIViewController { get }
    func start()
}

internal class ComponentContainerRouter: ComponentContainerRouterProtocol {

    // MARK: - Properties

    internal weak var delegate: ComponentContainerRouterDelegate?
    private let view: UIViewController
    private var viewModel: ComponentContainerViewModelProtocol

    // MARK: - Initializers

    internal init(
        view: UIViewController,
        viewModel: ComponentContainerViewModelProtocol
    ) {
        self.view = view
        self.viewModel = viewModel
        self.viewModel.delegate = self
    }

    // MARK: - ComponentContainerRouterProtocol

    internal var rootViewController: UIViewController {
        // TODO: - Handle alert view controller scenario [STORED PAYMENT METHODS]
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
