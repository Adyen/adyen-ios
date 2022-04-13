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
        guard let paymentMethods = paymentMethods else { return }

        let configuration = DropInComponent.Configuration(apiContext: apiContext)

        if let applePayPayment = try? ApplePayPayment(payment: payment) {
            configuration.applePay = .init(payment: applePayPayment,
                                           merchantIdentifier: ConfigurationConstants.applePayMerchantIdentifier)
        }

        configuration.actionComponent.threeDS.requestorAppURL = URL(string: ConfigurationConstants.returnUrl)
        configuration.payment = payment
        configuration.card.billingAddressMode = .postalCode
        configuration.paymentMethodsList.allowDisablingStoredPaymentMethods = true

        let component = DropInComponent(paymentMethods: paymentMethods,
                                        configuration: configuration,
                                        title: ConfigurationConstants.appName)
        component.delegate = self
        component.partialPaymentDelegate = self
        component.storedPaymentMethodsDelegate = self
        currentComponent = component

        presenter?.present(viewController: component.viewController, completion: nil)
    }

    // MARK: - Payment response handling

    private func paymentResponseHandler(result: Result<PaymentsResponse, Error>) {
        switch result {
        case let .success(response):
            if let action = response.action {
                handle(action)
            } else if let order = response.order,
                      let remainingAmount = order.remainingAmount,
                      remainingAmount.value > 0 {
                handle(order)
            } else {
                finish(with: response.resultCode)
            }
        case let .failure(error):
            finish(with: error)
        }
    }

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
