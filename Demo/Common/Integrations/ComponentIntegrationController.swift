//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenCard
import AdyenComponents
import AdyenDropIn
import UIKit

internal final class ComponentIntegrationController: AdyenIntegrationController {

    // MARK: - Styles

    private lazy var formStyle = FormComponentStyle()
    private lazy var listStyle = ListComponentStyle()

    // MARK: - Presentation

    private lazy var actionComponent: AdyenActionComponent = {
        let handler = AdyenActionComponent()
        handler.delegate = self
        handler.environment = environment
        handler.clientKey = Configuration.clientKey
        handler.presentationDelegate = self

        return handler
    }()

    private func present(_ component: PresentableComponent) {
        component.environment = environment
        component.clientKey = Configuration.clientKey
        component.payment = payment

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
        currentComponent?.didCancel()

        if let paymentComponent = currentComponent as? PaymentComponent {
            paymentComponent.delegate?.didFail(with: ComponentError.cancelled, from: paymentComponent)
        }
    }

    // MARK: - Standalone Components

    internal func Card() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: CardPaymentMethod.self) else { return }
        let component = CardComponent(paymentMethod: paymentMethod,
                                      configuration: CardComponent.Configuration(),
                                      clientKey: Configuration.clientKey,
                                      style: formStyle)
        component.environment = environment
        component.clientKey = Configuration.clientKey
        component.cardComponentDelegate = self
        present(component)
    }

    internal func Ideal() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: IssuerListPaymentMethod.self) else { return }
        let component = IdealComponent(paymentMethod: paymentMethod,
                                       style: listStyle)
        present(component)
    }

    internal func SEPADirectDebit() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: SEPADirectDebitPaymentMethod.self) else { return }
        let component = SEPADirectDebitComponent(paymentMethod: paymentMethod,
                                                 style: formStyle)
        component.delegate = self
        present(component)
    }

    internal func MBWay() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: MBWayPaymentMethod.self) else { return }
        let component = MBWayComponent(paymentMethod: paymentMethod,
                                       style: formStyle)
        component.delegate = self
        present(component)
    }

    internal func ApplePay() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: ApplePayPaymentMethod.self) else { return }
        let config = ApplePayComponent.Configuration(paymentMethod: paymentMethod,
                                                     summaryItems: Configuration.applePaySummaryItems,
                                                     merchantIdentifier: Configuration.applePayMerchantIdentifier)
        let component = try? ApplePayComponent(payment: payment,
                                               configuration: config) {
            print("ApplePay dismissed")
        }
        component?.delegate = self
        guard let presentableComponent = component else { return }
        present(presentableComponent)
    }

    // MARK: - Action handling

    override internal func handle(_ action: Action) {
        guard paymentInProgress else { return }
        actionComponent.perform(action)
    }

}

extension ComponentIntegrationController: PaymentComponentDelegate {

    internal func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        paymentInProgress = true
        performPayment(with: data)
    }

    internal func didFail(with error: Error, from component: PaymentComponent) {
        paymentInProgress = false
        finish(with: error)
    }

}

extension ComponentIntegrationController: ActionComponentDelegate {

    internal func didFail(with error: Error, from component: ActionComponent) {
        paymentInProgress = false
        finish(with: error)
    }

    internal func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        performPaymentDetails(with: data)
    }

}

extension ComponentIntegrationController: CardComponentDelegate {

    internal func didChangeBIN(_ value: String, component: CardComponent) {
        print("Current BIN: \(value)")
    }

    internal func didChangeCardBrand(_ value: [CardBrand]?, component: CardComponent) {
        print("Current card type: \((value ?? []).reduce("") { "\($0), \($1)" })")
    }

}

extension ComponentIntegrationController: PresentationDelegate {

    internal func present(component: PresentableComponent, disableCloseButton: Bool) {
        return present(component)
    }

}
