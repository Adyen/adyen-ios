//
// Copyright (c) 2022 Adyen N.V.
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
        let component = CardComponent(paymentMethod: paymentMethod,
                                      apiContext: apiContext)
        component.cardComponentDelegate = self
        present(component)
    }

    internal func presentIdealComponent() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: IssuerListPaymentMethod.self) else { return }
        let component = IdealComponent(paymentMethod: paymentMethod,
                                       apiContext: apiContext)
        present(component)
    }

    internal func presentSEPADirectDebitComponent() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: SEPADirectDebitPaymentMethod.self) else { return }
        let component = SEPADirectDebitComponent(paymentMethod: paymentMethod,
                                                 apiContext: apiContext)
        present(component)
    }

    internal func presentBACSDirectDebitComponent() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: BACSDirectDebitPaymentMethod.self) else { return }
        let component = BACSDirectDebitComponent(paymentMethod: paymentMethod,
                                                 apiContext: apiContext)
        bacsDirectDebitPresenter = BACSDirectDebitPresentationDelegate(bacsComponent: component)
        component.presentationDelegate = bacsDirectDebitPresenter
        present(component)
    }

    internal func presentMBWayComponent() {
        let style = FormComponentStyle()
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: MBWayPaymentMethod.self) else { return }
        let config = MBWayComponent.Configuration(style: style)
        let component = MBWayComponent(paymentMethod: paymentMethod,
                                       apiContext: apiContext,
                                       configuration: config)
        present(component)
    }

    internal func presentApplePayComponent() {
        guard
            let paymentMethod = paymentMethods?.paymentMethod(ofType: ApplePayPaymentMethod.self),
            let applePayPayment = try? ApplePayPayment(payment: payment)
        else { return }
        let config = ApplePayComponent.Configuration(payment: applePayPayment,
                                                     merchantIdentifier: ConfigurationConstants.applePayMerchantIdentifier,
                                                     allowOnboarding: true)
        let component = try? ApplePayComponent(paymentMethod: paymentMethod,
                                               apiContext: apiContext,
                                               configuration: config)
        guard let presentableComponent = component else { return }
        present(presentableComponent)
    }

    internal func presentConvenienceStore() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: EContextPaymentMethod.self) else { return }
        let component = EContextStoreComponent(paymentMethod: paymentMethod,
                                               apiContext: apiContext,
                                               configuration: BasicPersonalInfoFormComponent.Configuration(style: FormComponentStyle()))
        present(component)
    }

    // MARK: - Presentation

    private func present(_ component: PresentableComponent) {
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
        component.viewController.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .cancel,
                                                                           target: self,
                                                                           action: #selector(cancelDidPress))
        presenter?.present(viewController: navigation, completion: nil)
    }

    @objc private func cancelDidPress() {
        currentComponent?.cancelIfNeeded()
        presenter?.dismiss(completion: nil)
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

    internal func handle(_ action: Action) {
        if let dropInAsActionComponent = currentComponent as? ActionHandlingComponent {
            /// In case current component is a `DropInComponent` that implements `ActionHandlingComponent`
            dropInAsActionComponent.handle(action)
        } else {
            /// In case current component is an individual component like `CardComponent`
            adyenActionComponent.handle(action)
        }
    }

}

extension IntegrationExample: PaymentComponentDelegate {

    internal func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        let request = PaymentsRequest(data: data)
        apiClient.perform(request, completionHandler: paymentResponseHandler)
    }

    internal func didFail(with error: Error, from component: PaymentComponent) {
        finish(with: error)
    }

}

extension IntegrationExample: ActionComponentDelegate {

    internal func didFail(with error: Error, from component: ActionComponent) {
        finish(with: error)
    }

    internal func didComplete(from component: ActionComponent) {
        finish(with: .authorised)
    }

    internal func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        (component as? PresentableComponent)?.viewController.view.isUserInteractionEnabled = false
        let request = PaymentDetailsRequest(
            details: data.details,
            paymentData: data.paymentData,
            merchantAccount: ConfigurationConstants.current.merchantAccount
        )
        apiClient.perform(request, completionHandler: paymentResponseHandler)
    }
}

extension IntegrationExample: CardComponentDelegate {
    func didSubmit(lastFour value: String, component: CardComponent) {
        print("Card used: **** **** **** \(value)")
    }

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
