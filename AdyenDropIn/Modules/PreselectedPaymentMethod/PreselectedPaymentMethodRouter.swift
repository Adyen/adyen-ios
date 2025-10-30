//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol PreselectedPaymentMethodRouterListener: AnyObject {
    func didPresentPaymentMethodList()
}

internal protocol PreselectedPaymentMethodRouting: AnyObject {
    func presentPaymentMethodList()
    func presentComponent(_ component: any PresentableComponent)
    func dismissPresentedComponent()
}

internal class PreselectedPaymentMethodRouter: Router, PreselectedPaymentMethodRouting {
    
    // MARK: - Properties

    internal let rootViewController: UIViewController
    private let loadable: LoadControllable
    private weak var listener: PreselectedPaymentMethodRouterListener?
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    private var childRouter: Router?

    // MARK: - Initializers
    
    internal init(
        viewController: UIViewController,
        loadable: LoadControllable,
        listener: PreselectedPaymentMethodRouterListener?,
        componentContainerAssembler: ComponentContainerAssemblerProtocol
    ) {
        self.rootViewController = viewController
        self.loadable = loadable
        self.listener = listener
        self.componentContainerAssembler = componentContainerAssembler
    }

    // MARK: - PreselectedPaymentMethodRouting

    internal func presentPaymentMethodList() {
        listener?.didPresentPaymentMethodList()
    }

    internal func presentComponent(_ component: any PresentableComponent) {
        let componentContainerRouter = componentContainerAssembler.resolveComponentContainerRouter(
            for: component,
            delegate: self
        )
        self.childRouter = componentContainerRouter
        rootViewController.present(componentContainerRouter.rootViewController, animated: true)
    }
    
    internal func dismissPresentedComponent() {
        rootViewController.dismiss(animated: true)
    }
    
    // MARK: - Router
    
    internal func stopLoading() {
        loadable.stopLoading()
    }
}

// MARK: - ComponentContainerRouterListener

extension PreselectedPaymentMethodRouter: ComponentContainerRouterListener {
    
    internal func didDismiss() {
        stopLoading()
        childRouter = nil
    }
}
