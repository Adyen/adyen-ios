//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenComponents
import AdyenSession

internal final class ApplePayComponentExample: InitialDataFlowProtocol {

    // MARK: - Properties

    internal var session: AdyenSession?
    internal weak var presenter: PresenterExampleProtocol?
    internal var applePayComponent: ApplePayComponent?

    // MARK: - Initializers

    internal init() {}

    // MARK: - Networking

    internal func requestInitialData(completion: ((PaymentMethods?, Error?) -> Void)?) {
        requestAdyenSessionConfiguration { [weak self] adyenSessionConfig, errorResponse in
            guard let self = self else {
                return
            }
            guard let config = adyenSessionConfig else {
                return
            }
            AdyenSession.initialize(with: config,
                                    delegate: self,
                                    presentationDelegate: self) { [weak self] result in
                switch result {
                case let .success(session):
                    self?.session = session
                case let .failure(errorResponse):
                    self?.presentAlert(with: errorResponse)
                }
            }
        }
    }

    // MARK: Apple Pay

    internal func present() {
        guard let component = applePayComponent(from: session?.sessionContext.paymentMethods) else { return }
        component.delegate = session
        applePayComponent = component
        present(component)
    }

    internal func applePayComponent(from paymentMethods: PaymentMethods?) -> ApplePayComponent? {
        guard
            let paymentMethod = paymentMethods?.paymentMethod(ofType: ApplePayPaymentMethod.self),
            let applePayPayment = try? ApplePayPayment(payment: ConfigurationConstants.current.payment,
                                                       brand: ConfigurationConstants.appName)
        else { return nil }
        var config = ApplePayComponent.Configuration(payment: applePayPayment,
                                                     merchantIdentifier: ConfigurationConstants.applePayMerchantIdentifier)
        config.allowOnboarding = true
        config.supportsCouponCode = true
        config.shippingType = .delivery
        config.requiredShippingContactFields = [.postalAddress]
        config.requiredBillingContactFields = [.postalAddress]
        config.shippingMethods = ConfigurationConstants.shippingMethods

        let component = try? ApplePayComponent(paymentMethod: paymentMethod,
                                               context: context,
                                               configuration: config)
        return component
    }

    private func present(_ component: PresentableComponent) {
        presenter?.present(viewController: component.viewController, completion: nil)
    }

    // MARK: - Alert handling

    internal func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        presenter?.presentAlert(with: error, retryHandler: retryHandler)
    }

    internal func dismissAndShowAlert(_ success: Bool, _ message: String) {
        presenter?.dismiss {
            // Payment is processed. Add your code here.
            let title = success ? "Success" : "Error"
            self.presenter?.presentAlert(withTitle: title, message: message)
        }
    }

}

extension ApplePayComponentExample: AdyenSessionDelegate {

    func didComplete(with resultCode: SessionPaymentResultCode, component: Component, session: AdyenSession) {
        requestInitialData() { _, _ in }
        dismissAndShowAlert(resultCode.isSuccess, resultCode.rawValue)
    }

    func didFail(with error: Error, from component: Component, session: AdyenSession) {
        requestInitialData() { _, _ in }
        dismissAndShowAlert(false, error.localizedDescription)
    }

    func didOpenExternalApplication(component: ActionComponent, session: AdyenSession) {}

}

extension ApplePayComponentExample: PresentationDelegate {
    internal func present(component: PresentableComponent) {}
}
