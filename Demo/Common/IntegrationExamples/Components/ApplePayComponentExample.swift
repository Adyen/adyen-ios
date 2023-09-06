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

    internal func start() {
        presenter?.showLoadingIndicator()
        loadSession { [weak self] response in
            guard let self else { return }

            self.presenter?.hideLoadingIndicator()

            switch response {
            case let .success(session):
                self.session = session
                self.presentComponent(with: session)

            case let .failure(error):
                self.presentAlert(with: error)
            }
        }
    }

    // MARK: - Networking

    internal func loadSession(completion: @escaping (Result<AdyenSession, Error>) -> Void) {
        requestAdyenSessionConfiguration { [weak self] response in
            guard let self else { return }
            switch response {
            case let .success(configuration):
                AdyenSession.initialize(with: configuration,
                                        delegate: self,
                                        presentationDelegate: self,
                                        completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // MARK: Presentation

    internal func presentComponent(with session: AdyenSession) {
        do {
            let component = try applePayComponent(from: session)
            let componentViewController = component.viewController
            presenter?.present(viewController: componentViewController, completion: nil)
            applePayComponent = component
        } catch {
            self.presentAlert(with: error)
        }
    }

    internal func applePayComponent(from session: AdyenSession) throws -> ApplePayComponent {
        let paymentMethods = session.sessionContext.paymentMethods
        guard let paymentMethod = paymentMethods.paymentMethod(ofType: ApplePayPaymentMethod.self) else {
            throw IntegrationError.paymentMethodNotAvailable(paymentMethod: CardPaymentMethod.self)
        }
        let applePayPayment = try ApplePayPayment(payment: ConfigurationConstants.current.payment,
                                                  brand: ConfigurationConstants.appName)
        var config = ApplePayComponent.Configuration(payment: applePayPayment,
                                                     merchantIdentifier:
                                                     ConfigurationConstants.current.applePayConfiguration.merchantIdentifier)
        config.allowOnboarding = ConfigurationConstants.current.applePayConfiguration.allowOnboarding
        config.shippingType = .delivery
        config.requiredShippingContactFields = [.postalAddress]
        config.requiredBillingContactFields = [.postalAddress]

        let component = try ApplePayComponent(paymentMethod: paymentMethod,
                                              context: context,
                                              configuration: config)
        component.delegate = session
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
    
    func didComplete(with result: AdyenSessionResult, component: Component, session: AdyenSession) {
        dismissAndShowAlert(result.resultCode.isSuccess, result.resultCode.rawValue)
    }

    func didFail(with error: Error, from component: Component, session: AdyenSession) {
        dismissAndShowAlert(false, error.localizedDescription)
    }

    func didOpenExternalApplication(component: ActionComponent, session: AdyenSession) {}

}

extension ApplePayComponentExample: PresentationDelegate {
    // The implementation of this delegate method is not needed when using AdyenSession
    internal func present(component: PresentableComponent) {}

}
