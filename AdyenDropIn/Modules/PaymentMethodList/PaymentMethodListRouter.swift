//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol PaymentMethodListRouterDelegate: AnyObject {
    func paymentMethodListDidCancel(completion: (() -> Void)?)
    func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent)
    func didFail(with error: any Error)
    func didCancel(component: any PaymentComponent)
}

internal protocol PaymentMethodListRouterProtocol: AnyObject {
    func didCancel(completion: (() -> Void)?)
    func didSelect(_ component: PresentableComponent)
    func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent)
    func didFail(with error: any Error)
    func didCancel(component: any PaymentComponent)
}

internal class PaymentMethodListRouter: Router, PaymentMethodListRouterProtocol {

    // MARK: - Properties

    private let viewController: UIViewController
    private weak var delegate: PaymentMethodListRouterDelegate?
    private let navigationController = UINavigationController()
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    private var componentContainerRouter: Router?

    // MARK: - Initializers

    internal init(
        viewController: UIViewController,
        delegate: PaymentMethodListRouterDelegate?,
        componentContainerAssembler: ComponentContainerAssemblerProtocol
    ) {
        self.viewController = viewController
        self.delegate = delegate
        self.componentContainerAssembler = componentContainerAssembler
    }
    
    // MARK: - Router
    
    internal var rootViewController: UIViewController {
        navigationController.setViewControllers([viewController], animated: false)
        return navigationController
    }

    // MARK: - PaymentMethodListRouterProtocol

    internal func didCancel(completion: (() -> Void)?) {
        delegate?.paymentMethodListDidCancel(completion: completion)
        componentContainerRouter = nil
    }

    internal func didSelect(_ component: PresentableComponent) {
        let componentContainerRouter = componentContainerAssembler.resolveComponentContainerRouter(
            for: component,
            delegate: self
        )
        self.componentContainerRouter = componentContainerRouter

        let componentContainerViewController = componentContainerRouter.rootViewController

        // TODO: - Invert `requiresModalPresentation` logic or remove it fully.
        if component.requiresModalPresentation {
            viewController.navigationController?.pushViewController(componentContainerViewController, animated: true)
        } else {
            viewController.present(componentContainerViewController, animated: true)
        }
    }
}

extension PaymentMethodListRouter: ComponentContainerRouterDelegate {

    // MARK: - PaymentComponentDelegate

    func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent) {
        delegate?.didSubmit(data, from: component)
    }
    
    func didFail(with error: any Error) {
        delegate?.didFail(with: error)
    }
    
    func didCancel(component: any PaymentComponent) {
        delegate?.didCancel(component: component)
    }
}
