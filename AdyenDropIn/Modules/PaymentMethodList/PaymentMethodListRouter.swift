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
    
    func didOpenExternalApplication(component: ActionComponent)
    func didProvide(_ data: ActionComponentData, from component: ActionComponent)
    func didComplete(from component: ActionComponent)
    func didFail(with error: Error, from component: ActionComponent)
}

internal protocol PaymentMethodListRouterProtocol: AnyObject {
    var rootViewController: UIViewController { get }
    var delegate: PaymentMethodListRouterDelegate? { get set }
}

internal class PaymentMethodListRouter: PaymentMethodListRouterProtocol {

    // MARK: - Properties

    internal weak var delegate: PaymentMethodListRouterDelegate?
    private let navigationController = UINavigationController()
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    private var componentContainerRouter: ComponentContainerRouterProtocol?
    internal var view: UIViewController?

    // MARK: - Initializers

    internal init(componentContainerAssembler: ComponentContainerAssemblerProtocol) {
        self.componentContainerAssembler = componentContainerAssembler
    }

    // MARK: - PaymentMethodListRouterProtocol

    internal var rootViewController: UIViewController {
        guard let view else {
            fatalError("Router's view was not set.")
        }

        navigationController.setViewControllers([view], animated: false)
        return navigationController
    }

    // MARK: - Private
}

extension PaymentMethodListRouter: PaymentMethodListViewModelDelegate {

    // MARK: - PaymentMethodListViewModelDelegate

    func didCancel(completion: (() -> Void)?) {
        delegate?.paymentMethodListDidCancel(completion: completion)
        componentContainerRouter = nil
    }

    internal func didSelect(_ component: PresentableComponent) {
        let componentContainerRouter = componentContainerAssembler.resolveComponentContainerRouter(
            for: component,
            delegate: self
        )
        self.componentContainerRouter = componentContainerRouter

        componentContainerRouter.start()

        let componentContainerViewController = componentContainerRouter.rootViewController

        // TODO: - Invert `requiresModalPresentation` logic or remove it fully.
        if component.requiresModalPresentation {
            view?.navigationController?.pushViewController(componentContainerViewController, animated: true)
        } else {
            view?.present(componentContainerViewController, animated: true)
        }
    }
}

extension PaymentMethodListRouter: ComponentContainerRouterDelegate {

    // MARK: - ComponentContainerRouterDelegate

    func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent) {
        delegate?.didSubmit(data, from: component)
    }
    
    func didFail(with error: any Error) {
        delegate?.didFail(with: error)
    }
    
    func didCancel(component: any PaymentComponent) {
        delegate?.didCancel(component: component)
    }
    
    func didOpenExternalApplication(component: any ActionComponent) {
        delegate?.didOpenExternalApplication(component: component)
    }
    
    func didProvide(_ data: ActionComponentData, from component: any ActionComponent) {
        delegate?.didProvide(data, from: component)
    }
    
    func didComplete(from component: any ActionComponent) {
        delegate?.didComplete(from: component)
    }
    
    func didFail(with error: any Error, from component: any ActionComponent) {
        delegate?.didFail(with: error, from: component)
    }
}
