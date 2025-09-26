//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif

internal protocol DropInViewModelProtocol {
    var root: DropInRoot { get }
    func handle(action: Action)
}

internal class DropInViewModel: DropInViewModelProtocol {

    // MARK: - Properties

    internal weak var router: DropInRouterProtocol?
    private let componentManager: ComponentManager
    private let apiClient: APIClientProtocol
    private let paymentMethods: PaymentMethods
    private let context: AdyenContext
    private let configuration: DropInComponent.Configuration
    private let title: String?

    // MARK: - Initializers

    internal init(
        componentManager: ComponentManager,
        apiClient: APIClientProtocol,
        paymentMethods: PaymentMethods,
        context: AdyenContext,
        configuration: DropInComponent.Configuration,
        title: String? = nil
    ) {
        self.componentManager = componentManager
        self.apiClient = apiClient
        self.paymentMethods = paymentMethods
        self.context = context
        self.configuration = configuration
        self.title = title

        self.componentManager.presentationDelegate = self
    }

    // MARK: - DropInRootViewModelProtocol

    internal var root: DropInRoot {
        if configuration.allowPreselectedPaymentView, let storedPaymentMethod = componentManager.storedComponents.first {
            return .preselected(storedPaymentMethod)
        } else if configuration.allowsSkippingPaymentList, let paymentComponent = componentManager.singleRegularComponent {
            return .component(paymentComponent)
        } else {
            return .paymentMethodList
        }
    }
    
    internal func handle(action: Action) {
        // TODO: - Handle action
        actionComponent.handle(action)
    }
    
    // MARK: - Private
    
    private lazy var actionComponent: AdyenActionComponent = {
        let actionComponent = AdyenActionComponent(context: context)
        actionComponent.delegate = self
        actionComponent.presentationDelegate = self
        actionComponent.configuration.style = configuration.style.actionComponent
        actionComponent.configuration.localizationParameters = configuration.localizationParameters
        actionComponent.configuration.threeDS = configuration.actionComponent.threeDS
        actionComponent.configuration.twint = configuration.actionComponent.twint
        return actionComponent
    }()
}

// MARK: - ActionComponentDelegate

extension DropInViewModel: ActionComponentDelegate {
    
    func didOpenExternalApplication(component: any ActionComponent) {
        component.stopLoadingIfNeeded()
        router?.didOpenExternalApplication(component: component)
    }

    func didProvide(_ data: ActionComponentData, from component: any ActionComponent) {
        router?.didProvide(data, from: component)
    }
    
    func didComplete(from component: any ActionComponent) {
        router?.didComplete(from: component)
    }
    
    func didFail(with error: any Error, from component: any ActionComponent) {
        if case ComponentError.cancelled = error {
            // TODO: - Handle action cancel
        } else {
            router?.didFail(with: error, from: component)
        }
    }
}

// MARK: - PresentationDelegate

extension DropInViewModel: PresentationDelegate {

    internal func present(component: any PresentableComponent) {
        let componentViewController = component.viewController
        router?.present(componentViewController, animated: true)
    }
}
