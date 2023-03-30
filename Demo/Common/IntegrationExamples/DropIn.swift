//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenActions
import AdyenCard
import AdyenComponents
import AdyenDropIn
import AdyenNetworking
import AdyenSession
import UIKit

internal final class DropIn: DropInExampleProtocol {

    // MARK: - Properties

    internal var dropInComponent: PresentableComponent?
    internal weak var presenter: PresenterExampleProtocol?
    internal var paymentMethods: PaymentMethods?
    internal var session: AdyenSession?
    private lazy var containerView = UIView()
    private lazy var loadingView = LoadingView(contentView: containerView)

    // MARK: - Initializers

    internal init() {}

    // MARK: - Networking

    internal func requestInitialData() {
        requestAdyenSessionConfiguration { adyenSessionConfig, errorResponse in
            guard let config = adyenSessionConfig else {
                return
            }
            AdyenSession.initialize(with: config,
                                    delegate: self,
                                    presentationDelegate: self) { [weak self] result in
                switch result {
                case let .success(session):
                    self?.session = session
                    self?.paymentMethods = session.sessionContext.paymentMethods
                    self?.loadingView.showsActivityIndicator = false
                case let .failure(errorResponse):
                    self?.presentAlert(with: errorResponse)
                    self?.loadingView.showsActivityIndicator = false
                }
            }
        }
    }

    internal func presentDropInComponentSession() {
        guard let dropIn = dropInComponent(from: paymentMethods) else { return }

        dropIn.delegate = session
        dropIn.partialPaymentDelegate = session
        dropInComponent = dropIn

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

extension DropIn: AdyenSessionDelegate {

    func didComplete(with resultCode: SessionPaymentResultCode, component: Component, session: AdyenSession) {
        requestInitialData()
        dismissAndShowAlert(resultCode.isSuccess, resultCode.rawValue)
    }

    func didFail(with error: Error, from component: Component, session: AdyenSession) {
        requestInitialData()
        dismissAndShowAlert(false, error.localizedDescription)
    }

    func didOpenExternalApplication(component: ActionComponent, session: AdyenSession) {}

}

extension DropIn: PresentationDelegate {
    internal func present(component: PresentableComponent) {}
}
