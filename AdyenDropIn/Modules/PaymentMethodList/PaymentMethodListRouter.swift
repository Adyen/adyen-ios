//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol PaymentMethodListRouterProtocol: AnyObject {
    var rootViewController: UIViewController { get }
    func start()
    var delegate: PaymentMethodListRouterDelegate? { get set }
    func cancel(completion: (() -> Void)?)
    func didLoad()
    func didSelect(_ component: PresentableComponent)
    func delete(
        storedPaymentMethod: StoredPaymentMethod,
        completion: @escaping (Bool) -> Void
    )
}

internal protocol PaymentMethodListRouterDelegate: AnyObject {
    func cancelPayment(completion: (() -> Void)?)
}

internal class PaymentMethodListRouter: PaymentMethodListRouterProtocol {

    // MARK: - Properties

    private let navigationController = UINavigationController()
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    internal var view: UIViewController?
    internal weak var delegate: PaymentMethodListRouterDelegate?

    // MARK: - Initializers

    internal init(componentContainerAssembler: ComponentContainerAssemblerProtocol) {
        self.componentContainerAssembler = componentContainerAssembler
    }

    // MARK: - PaymentMethodListRouterProtocol

    internal var rootViewController: UIViewController {
        navigationController
    }

    internal func start() {
        guard let view else {
            fatalError("Router's view was not set.")
        }

        navigationController.setViewControllers([view], animated: false)
    }

    internal func cancel(completion: (() -> Void)?) {
        delegate?.cancelPayment(completion: completion)
    }

    internal func didLoad() {
        // TODO: -
        print("Payment method list did load")
    }

    internal func didSelect(_ component: PresentableComponent) {
        let componentViewController = componentContainerAssembler.resolveContainerView(for: component)
        view?.navigationController?.pushViewController(componentViewController, animated: true)
    }

    internal func delete(
        storedPaymentMethod: any Adyen.StoredPaymentMethod,
        completion: @escaping (Bool) -> Void
    ) {
        // TODO: -
    }

    // MARK: - Private
}
