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

    // MARK: Card

    internal func presentCardComponent() {
        guard let component = cardComponent(from: paymentMethods) else { return }
        component.cardComponentDelegate = self
        present(component, delegate: self)
    }

    internal func presentCardComponentSession() {
        guard let component = cardComponent(from: sessionPaymentMethods) else { return }
        component.cardComponentDelegate = self
        present(component, delegate: session)
    }

    internal func cardComponent(from paymentMethods: PaymentMethods?) -> CardComponent? {
        guard let paymentMethods = paymentMethods,
              let paymentMethod = paymentMethods.paymentMethod(ofType: CardPaymentMethod.self) else { return nil }
        return CardComponent(paymentMethod: paymentMethod, apiContext: ConfigurationConstants.apiContext)
    }

    // MARK: IDEAL

    internal func presentIdealComponent() {
        guard let component = idealComponent(from: paymentMethods) else { return }
        present(component, delegate: self)
    }

    internal func presentIdealComponentSession() {
        guard let component = idealComponent(from: sessionPaymentMethods) else { return }
        present(component, delegate: session)
    }

    internal func idealComponent(from paymentMethods: PaymentMethods?) -> IdealComponent? {
        guard let paymentMethods = paymentMethods,
              let paymentMethod = paymentMethods.paymentMethod(ofType: IssuerListPaymentMethod.self) else { return nil }
        return IdealComponent(paymentMethod: paymentMethod, apiContext: ConfigurationConstants.apiContext)
    }

    // MARK: SEPA

    internal func presentSEPADirectDebitComponent() {
        guard let component = sepaComponent(from: paymentMethods) else { return }
        present(component, delegate: self)
    }

    internal func presentSEPADirectDebitComponentSession() {
        guard let component = sepaComponent(from: sessionPaymentMethods) else { return }
        present(component, delegate: session)
    }

    internal func sepaComponent(from paymentMethods: PaymentMethods?) -> SEPADirectDebitComponent? {
        guard let paymentMethods = paymentMethods,
              let paymentMethod = paymentMethods.paymentMethod(ofType: SEPADirectDebitPaymentMethod.self) else { return nil }
        return SEPADirectDebitComponent(paymentMethod: paymentMethod, apiContext: ConfigurationConstants.apiContext)
    }

    // MARK: MBWay

    internal func presentMBWayComponent() {
        guard let component = mbWayComponent(from: paymentMethods) else { return }
        present(component, delegate: self)
    }

    internal func presentMBWayComponentSession() {
        guard let component = mbWayComponent(from: sessionPaymentMethods) else { return }
        present(component, delegate: session)
    }

    internal func mbWayComponent(from paymentMethods: PaymentMethods?) -> MBWayComponent? {
        guard let paymentMethods = paymentMethods,
              let paymentMethod = paymentMethods.paymentMethod(ofType: MBWayPaymentMethod.self) else { return nil }
        let style = FormComponentStyle()
        let config = MBWayComponent.Configuration(style: style)
        return MBWayComponent(paymentMethod: paymentMethod,
                              apiContext: ConfigurationConstants.apiContext,
                              configuration: config)
    }

    // MARK: Apple Pay

    internal func presentApplePayComponent() {
        guard let component = applePayComponent(from: paymentMethods) else { return }
        present(component, delegate: self)
    }
    
    internal func presentApplePayComponentSession() {
        guard let component = applePayComponent(from: sessionPaymentMethods) else { return }
        present(component, delegate: session)
    }
    
    internal func applePayComponent(from paymentMethods: PaymentMethods?) -> ApplePayComponent? {
        guard
            let paymentMethod = paymentMethods?.paymentMethod(ofType: ApplePayPaymentMethod.self),
            let applePayPayment = try? ApplePayPayment(payment: payment)
        else { return nil }
        var config = ApplePayComponent.Configuration(payment: applePayPayment,
                                                     merchantIdentifier: ConfigurationConstants.applePayMerchantIdentifier)
        config.allowOnboarding = true
        let component = try? ApplePayComponent(paymentMethod: paymentMethod,
                                               apiContext: ConfigurationConstants.apiContext,
                                               configuration: config)
        return component
    }

    // MARK: Convenience Store

    internal func presentConvenienceStore() {
        guard let component = convenienceStoreComponent(from: paymentMethods) else { return }
        present(component, delegate: self)
    }

    internal func presentConvenienceStoreSession() {
        guard let component = convenienceStoreComponent(from: sessionPaymentMethods) else { return }
        present(component, delegate: session)
    }

    internal func convenienceStoreComponent(from paymentMethods: PaymentMethods?) -> EContextStoreComponent? {
        guard let paymentMethods = paymentMethods,
              let paymentMethod = paymentMethods.paymentMethod(ofType: EContextPaymentMethod.self) else { return nil }
        return EContextStoreComponent(paymentMethod: paymentMethod,
                                      apiContext: ConfigurationConstants.apiContext,
                                      configuration: BasicPersonalInfoFormComponent.Configuration(style: FormComponentStyle()))
    }

    // MARK: BACS

    internal func presentBACSDirectDebitComponent() {
        guard let component = bacsComponent(from: paymentMethods) else { return }
        present(component, delegate: self)
    }
    
    internal func presentBACSDirectDebitComponentSession() {
        guard let component = bacsComponent(from: sessionPaymentMethods) else { return }
        present(component, delegate: session)
    }
    
    internal func bacsComponent(from paymentMethods: PaymentMethods?) -> BACSDirectDebitComponent? {
        guard let paymentMethods = paymentMethods,
              let paymentMethod = paymentMethods.paymentMethod(ofType: BACSDirectDebitPaymentMethod.self) else { return nil }
        let component = BACSDirectDebitComponent(paymentMethod: paymentMethod,
                                                 apiContext: ConfigurationConstants.apiContext)
        bacsDirectDebitPresenter = BACSDirectDebitPresentationDelegate(bacsComponent: component)
        component.presentationDelegate = bacsDirectDebitPresenter
        return component
    }

    // MARK: - Presentation

    private func present(_ component: PresentableComponent, delegate: (PaymentComponentDelegate & ActionComponentDelegate)?) {
        if let component = component as? PaymentAwareComponent {
            do {
                try component.update(payment: payment)
            } catch {
                finish(with: error)
            }
        }

        if let paymentComponent = component as? PaymentComponent {
            paymentComponent.delegate = delegate
        }

        if let actionComponent = component as? ActionComponent {
            actionComponent.delegate = delegate
        }

        currentComponent = component
        guard component.requiresModalPresentation else {
            presenter?.present(viewController: component.viewController, completion: nil)
            return
        }

        let navigation = UINavigationController(rootViewController: component.viewController)
        component.viewController.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .cancel,
                                                                           target: self,
                                                                           action: #selector(cancelPressed))
        presenter?.present(viewController: navigation, completion: nil)
    }

    @objc private func cancelPressed() {
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
                finish(with: response)
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
        finish(with: .received)
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
        present(component, delegate: self)
    }
}
