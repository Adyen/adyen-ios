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

final class DropInExample: InitialDataFlowProtocol {

    // MARK: - Properties

    weak var presenter: PresenterExampleProtocol?

    private var session: AdyenSession?
    private var dropInComponent: DropInComponent?
    
    // MARK: - Initializers

    init() {}

    func start() {
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

    private func loadSession(completion: @escaping (Result<AdyenSession, Error>) -> Void) {
        requestAdyenSessionConfiguration { [weak self] response in
            guard let self = self else { return }
            
            switch response {
            case let .success(config):
                AdyenSession.initialize(with: config,
                                        delegate: self,
                                        presentationDelegate: self,
                                        completion: completion)
                
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Presentation
    
    private func presentComponent(with session: AdyenSession) {
        let dropIn = dropInComponent(from: session)
        presenter?.present(viewController: dropIn.viewController, completion: nil)
        dropInComponent = dropIn
    }

    private func dropInComponent(from session: AdyenSession) -> DropInComponent {
        let paymentMethods = session.sessionContext.paymentMethods
        let configuration = dropInConfiguration(from: paymentMethods)
        let component = DropInComponent(paymentMethods: paymentMethods,
                                        context: context,
                                        configuration: configuration,
                                        title: ConfigurationConstants.appName)
        
        component.delegate = session
        component.partialPaymentDelegate = session

        return component
    }
    
    private func dropInConfiguration(from paymentMethods: PaymentMethods) -> DropInComponent.Configuration {
        let configuration = DropInComponent.Configuration()

        if let applePayPayment = try? ApplePayPayment(payment: ConfigurationConstants.current.payment,
                                                      brand: ConfigurationConstants.appName) {
            configuration.applePay = .init(payment: applePayPayment,
                                           merchantIdentifier: ConfigurationConstants.current.applePaySettings?.merchantIdentifier ?? "")
            configuration.applePay?.allowOnboarding = ConfigurationConstants.current.applePaySettings?.allowOnboarding ?? false
        }

        configuration.actionComponent.threeDS.delegateAuthentication = ConfigurationConstants.delegatedAuthenticationConfigurations
        configuration.card = ConfigurationConstants.current.cardDropInConfiguration
        configuration.allowsSkippingPaymentList = ConfigurationConstants.current.dropInSettings.allowsSkippingPaymentList
        configuration.allowPreselectedPaymentView = ConfigurationConstants.current.dropInSettings.allowPreselectedPaymentView
        // swiftlint:disable:next line_length
        configuration.paymentMethodsList.allowDisablingStoredPaymentMethods = ConfigurationConstants.current.dropInSettings.paymentMethodsList.allowDisablingStoredPaymentMethods
        return configuration
    }

    // MARK: - Alert handling

    private func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        presenter?.presentAlert(with: error, retryHandler: retryHandler)
    }

    private func dismissAndShowAlert(_ success: Bool, _ message: String) {
        presenter?.dismiss {
            // Payment is processed. Add your code here.
            let title = success ? "Success" : "Error"
            self.presenter?.presentAlert(withTitle: title, message: message)
        }
    }

}

extension DropInExample: AdyenSessionDelegate {

    func didComplete(with result: AdyenSessionResult, component: Component, session: AdyenSession) {
        dismissAndShowAlert(result.resultCode.isSuccess, result.resultCode.rawValue)
    }

    func didFail(with error: Error, from component: Component, session: AdyenSession) {
        dismissAndShowAlert(false, error.localizedDescription)
    }

    func didOpenExternalApplication(component: ActionComponent, session: AdyenSession) {}

}

extension DropInExample: PresentationDelegate {
    func present(component: PresentableComponent) {
        // The implementation of this delegate method is not needed when using AdyenSession as the session handles the presentation
    }
}
