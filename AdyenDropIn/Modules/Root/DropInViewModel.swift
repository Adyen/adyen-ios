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
    var title: String { get }
    func handle(action: Action)
}

internal class DropInViewModel: DropInViewModelProtocol {

    // MARK: - Properties

    internal weak var router: DropInRouting?
    internal let title: String
    private let componentManager: ComponentManager
    private let apiClient: APIClientProtocol
    private let paymentMethods: PaymentMethods
    private let context: AdyenContext
    private let configuration: DropInComponent.Configuration
    private weak var dropInComponent: DropInComponent?
    private weak var dropInComponentDelegate: DropInComponentDelegate?

    // MARK: - Initializers

    internal init(
        title: String,
        componentManager: ComponentManager,
        apiClient: APIClientProtocol,
        paymentMethods: PaymentMethods,
        context: AdyenContext,
        configuration: DropInComponent.Configuration,
        dropInComponent: DropInComponent,
        dropInComponentDelegate: DropInComponentDelegate?
    ) {
        self.title = title
        self.componentManager = componentManager
        self.apiClient = apiClient
        self.paymentMethods = paymentMethods
        self.context = context
        self.configuration = configuration
        self.dropInComponent = dropInComponent
        self.dropInComponentDelegate = dropInComponentDelegate

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
    
    internal func didOpenExternalApplication(component: any ActionComponent) {
        component.stopLoading()
        
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didOpenExternalApplication(component: component, in: dropInComponent)
    }

    internal func didProvide(_ data: ActionComponentData, from component: any ActionComponent) {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didProvide(data, from: component, in: dropInComponent)
    }
    
    internal func didComplete(from component: any ActionComponent) {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didComplete(from: component, in: dropInComponent)
    }
    
    internal func didFail(with error: any Error, from component: any ActionComponent) {
        guard let dropInComponent else { return }

        if case ComponentError.cancelled = error {
            router?.stopLoading()
        } else {
            dropInComponentDelegate?.didFail(with: error, from: component, in: dropInComponent)
        }
    }
}

// MARK: - PresentationDelegate

extension DropInViewModel: PresentationDelegate {

    internal func present(component: any PresentableComponent) {
        router?.presentActionComponent(component)
    }
}
