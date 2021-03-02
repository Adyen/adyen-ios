//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenCard
import AdyenComponents
import UIKit

extension IntegrationExample {

    // MARK: - Standalone Components

    internal func presentCardComponent() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: CardPaymentMethod.self) else { return }
        let style = FormComponentStyle()
        let component = CardComponent(paymentMethod: paymentMethod,
                                      configuration: CardComponent.Configuration(),
                                      clientKey: Configuration.clientKey,
                                      style: style)
        component.environment = environment
        component.clientKey = Configuration.clientKey
        component.cardComponentDelegate = self
        present(component)
    }

    internal func presentIdealComponent() {
        let style = ListComponentStyle()
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: IssuerListPaymentMethod.self) else { return }
        let component = IdealComponent(paymentMethod: paymentMethod,
                                       style: style)
        present(component)
    }

    internal func presentSEPADirectDebitComponent() {
        let style = FormComponentStyle()
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: SEPADirectDebitPaymentMethod.self) else { return }
        let component = SEPADirectDebitComponent(paymentMethod: paymentMethod,
                                                 style: style)
        component.delegate = self
        present(component)
    }

    internal func presentMBWayComponent() {
        let style = FormComponentStyle()
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: MBWayPaymentMethod.self) else { return }
        let component = MBWayComponent(paymentMethod: paymentMethod,
                                       style: style)
        component.delegate = self
        present(component)
    }

    internal func presentApplePayComponent() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: ApplePayPaymentMethod.self) else { return }
        let config = ApplePayComponent.Configuration(payment: payment,
                                                     paymentMethod: paymentMethod,
                                                     summaryItems: Configuration.applePaySummaryItems,
                                                     merchantIdentifier: Configuration.applePayMerchantIdentifier)
        let component = try? ApplePayComponent(configuration: config)
        component?.delegate = self
        guard let presentableComponent = component else { return }
        present(presentableComponent)
    }

    // MARK: - Presentation

    private func present(_ component: PresentableComponent) {
        component.environment = environment
        component.clientKey = Configuration.clientKey

        if let component = component as? PaymentAwareComponent {
            component.payment = payment
        }

        if let paymentComponent = component as? PaymentComponent {
            paymentComponent.delegate = self
        }

        if let actionComponent = component as? ActionComponent {
            actionComponent.delegate = self
        }

        currentComponent = component
        guard component.requiresModalPresentation else {
            presenter?.present(viewController: component.viewController, completion: nil)
            return
        }

        let navigation = UINavigationController(rootViewController: component.viewController)
        component.viewController.navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .cancel,
                                                                          target: self,
                                                                          action: #selector(cancelDidPress))
        presenter?.present(viewController: navigation, completion: nil)
    }

    @objc private func cancelDidPress() {
        (currentComponent as? Cancellable)?.didCancel()
        if let paymentComponent = self.currentComponent as? PaymentComponent {
            paymentComponent.delegate?.didFail(with: ComponentError.cancelled, from: paymentComponent)
        }
    }

    // MARK : - Payment response handling

    fileprivate func paymentResponseHandler(result: Result<PaymentsResponse, Error>) {
        switch result {
        case let .success(response):
            if let action = response.action {
                handle(action)
            } else {
                finish(with: response.resultCode)
            }
        case let .failure(error):
            finish(with: error)
        }
    }

    private func handle(_ action: Action) {
        guard paymentInProgress else { return }
        actionComponent.perform(action)
    }

}

extension IntegrationExample: PaymentComponentDelegate {

    internal func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        paymentInProgress = true
        let request = PaymentsRequest(data: data)
        apiClient.perform(request, completionHandler: paymentResponseHandler)
    }

    internal func didFail(with error: Error, from component: PaymentComponent) {
        paymentInProgress = false
        finish(with: error)
    }

}

extension IntegrationExample: ActionComponentDelegate {

    internal func didFail(with error: Error, from component: ActionComponent) {
        paymentInProgress = false
        finish(with: error)
    }

    internal func didComplete(from component: ActionComponent) {
        paymentInProgress = false
        finish(with: .authorised)
    }

    internal func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        let request = PaymentDetailsRequest(details: data.details,
                                            paymentData: data.paymentData,
                                            merchantAccount: Configuration.merchantAccount)
        apiClient.perform(request, completionHandler: paymentResponseHandler)
    }
}

extension IntegrationExample: CardComponentDelegate {
    internal func didChangeBIN(_ value: String, component: CardComponent) {
        print("Current BIN: \(value)")
    }

    internal func didChangeCardBrand(_ value: [CardBrand]?, component: CardComponent) {
        print("Current card type: \((value ?? []).reduce("") { "\($0), \($1)" })")
    }
}

extension IntegrationExample: PresentationDelegate {
    internal func present(component: PresentableComponent) {
        present(component)
    }
}
