//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenCard
import AdyenComponents
import AdyenDropIn
import UIKit

extension IntegrationExample {

    // MARK: - DropIn Component

    internal func presentDropInComponent() {
        guard let dropIn = dropInComponent(from: paymentMethods) else { return }
        
        dropIn.delegate = self
        dropIn.partialPaymentDelegate = self
        dropIn.storedPaymentMethodsDelegate = self
        currentComponent = dropIn

        presenter?.present(viewController: dropIn.viewController, completion: nil)
    }
    
    internal func presentDropInComponentSession() {
        guard let dropIn = dropInComponent(from: sessionPaymentMethods) else { return }
        
        dropIn.delegate = session
        dropIn.partialPaymentDelegate = session
        dropIn.storedPaymentMethodsDelegate = self
        currentComponent = dropIn

        presenter?.present(viewController: dropIn.viewController, completion: nil)
    }
    
    internal func dropInComponent(from paymentMethods: PaymentMethods?) -> DropInComponent? {
        guard let paymentMethods = paymentMethods else { return nil }

        let configuration = DropInComponent.Configuration()

        if let applePayPayment = try? ApplePayPayment(payment: ConfigurationConstants.current.payment,
                                                      brand: ConfigurationConstants.appName) {
            configuration.applePay = .init(payment: applePayPayment,
                                           merchantIdentifier: ConfigurationConstants.applePayMerchantIdentifier)
        }
        
        configuration.actionComponent.threeDS.delegateAuthentication = ConfigurationConstants.delegatedAuthenticationConfigurations
        configuration.actionComponent.threeDS.requestorAppURL = URL(string: ConfigurationConstants.returnUrl)
        configuration.card.billingAddress.mode = .postalCode
        configuration.paymentMethodsList.allowDisablingStoredPaymentMethods = true
        
        let component = DropInComponent(paymentMethods: paymentMethods,
                                        context: context,
                                        configuration: configuration,
                                        title: ConfigurationConstants.appName)
        
        return component
    }

    // MARK: - Payment response handling

    internal func handle(_ order: PartialPaymentOrder) {
        requestPaymentMethods(order: order) { [weak self] paymentMethods in
            self?.handle(order, paymentMethods)
        }
    }

    private func handle(_ order: PartialPaymentOrder, _ paymentMethods: PaymentMethods) {
        do {
            try (currentComponent as? DropInComponent)?.reload(with: order, paymentMethods)
        } catch {
            finish(with: error)
        }
    }
}

extension IntegrationExample: DropInComponentDelegate {
    
    func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent, in dropInComponent: AnyDropInComponent) {
        didSubmit(data, from: component)
    }
    
    func didFail(with error: Error, from component: PaymentComponent, in dropInComponent: AnyDropInComponent) {
        didFail(with: error, from: component)
    }
    
    func didProvide(_ data: ActionComponentData, from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didProvide(data, from: component)
    }
    
    func didComplete(from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didComplete(from: component)
    }
    
    func didFail(with error: Error, from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didFail(with: error, from: component)
    }
    
    internal func didCancel(component: PaymentComponent, from dropInComponent: AnyDropInComponent) {
        // Handle the event when the user closes a PresentableComponent.
        print("User did close: \(component.paymentMethod.name)")
    }
    
    internal func didFail(with error: Error, from dropInComponent: AnyDropInComponent) {
        finish(with: error)
    }

}

extension IntegrationExample: StoredPaymentMethodsDelegate {
    func disable(storedPaymentMethod: StoredPaymentMethod, completion: @escaping (Bool) -> Void) {
        let request = DisableStoredPaymentMethodRequest(recurringDetailReference: storedPaymentMethod.identifier)
        palApiClient.perform(request) { [weak self] result in
            self?.handleDisableResult(result, completion: completion)
        }
    }
    
    private func handleDisableResult(_ result: Result<DisableStoredPaymentMethodRequest.ResponseType, Error>, completion: (Bool) -> Void) {
        switch result {
        case let .failure(error):
            presentAlert(with: error, retryHandler: nil)
            completion(false)
        case let .success(response):
            completion(response.response == .detailsDisabled)
        }
    }
}
