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
        configuration.applePay = .init(summaryItems: ConfigurationConstants.applePaySummaryItems,
                                       merchantIdentifier: ConfigurationConstants.applePayMerchantIdentifier)
        configuration.payment = payment
        configuration.card.billingAddressMode = .postalCode
        configuration.paymentMethodsList.allowDisablingStoredPaymentMethods = true

        let dropInComponentStyle = DropInComponent.Style()
        let component = DropInComponent(paymentMethods: paymentMethods,
                                        configuration: configuration,
                                        style: dropInComponentStyle,
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

    private func handle(_ action: Action) {
        (currentComponent as? DropInComponent)?.handle(action)
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

    internal func didSubmit(_ data: PaymentComponentData, for paymentMethod: PaymentMethod, from component: DropInComponent) {
        print("User did start: \(paymentMethod.name)")
        let request = PaymentsRequest(data: data)
        apiClient.perform(request, completionHandler: paymentResponseHandler)
    }

    internal func didProvide(_ data: ActionComponentData, from component: DropInComponent) {
        component.viewController.view.isUserInteractionEnabled = false
        let request = PaymentDetailsRequest(
            details: data.details,
            paymentData: data.paymentData,
            merchantAccount: ConfigurationConstants.current.merchantAccount
        )
        apiClient.perform(request, completionHandler: paymentResponseHandler)
    }

    internal func didComplete(from component: DropInComponent) {
        finish(with: .authorised)
    }

    internal func didFail(with error: Error, from component: DropInComponent) {
        finish(with: error)
    }

    internal func didCancel(component: PaymentComponent, from dropInComponent: DropInComponent) {
        // Handle the event when the user closes a PresentableComponent.
        print("User did close: \(component.paymentMethod.name)")
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
