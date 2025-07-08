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
    var delegate: PaymentMethodListRouterDelegate? { get set }
    func start()
    func cancel(completion: (() -> Void)?)
    func didSelect(_ component: PresentableComponent)
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

    internal func didSelect(_ component: PresentableComponent) {
        if component.requiresModalPresentation {
            let componentContainerViewController = componentContainerAssembler.resolveContainerView(
                for: component
            )
            view?.navigationController?.pushViewController(componentContainerViewController, animated: true)
        } else {
            let componentContainerViewController = componentContainerAssembler.resolveContainerView(
                for: component
            )
            view?.present(componentContainerViewController, animated: true)
        }
    }

    // MARK: - Private
}
