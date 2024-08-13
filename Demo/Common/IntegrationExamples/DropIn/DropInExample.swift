//
// Copyright (c) 2024 Adyen N.V.
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

internal final class DropInExample: InitialDataFlowProtocol {

    // MARK: - Properties

    internal weak var presenter: PresenterExampleProtocol?

    private var session: AdyenSession?
    private var dropInComponent: DropInComponent?
    
    internal lazy var apiClient = ApiClientHelper.generateApiClient()
    
    internal lazy var context: AdyenContext = generateContext()
    
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

    private func loadSession(completion: @escaping (Result<AdyenSession, Error>) -> Void) {
        requestAdyenSessionConfiguration { [weak self] response in
            guard let self else { return }
            
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
                                        context: generateContext(),
                                        configuration: configuration,
                                        title: ConfigurationConstants.appName)
        
        component.delegate = session
        component.storedPaymentMethodsDelegate = session
        component.partialPaymentDelegate = session

        return component
    }
    
    private func dropInConfiguration(from paymentMethods: PaymentMethods) -> DropInComponent.Configuration {
        let configuration = ConfigurationConstants.current.dropInConfiguration

        configuration.applePay = try? ConfigurationConstants.current.applePayConfiguration()
        configuration.actionComponent.threeDS.delegateAuthentication = ConfigurationConstants.delegatedAuthenticationConfigurations
        configuration.card = ConfigurationConstants.current.cardDropInConfiguration
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
        if (error as? ComponentError) == .cancelled {
            presenter?.dismiss(completion: nil)
        } else {
            dismissAndShowAlert(false, error.localizedDescription)
        }
    }

    func didOpenExternalApplication(component: ActionComponent, session: AdyenSession) {}

}

extension DropInExample: PresentationDelegate {
    internal func present(component: PresentableComponent) {
        // The implementation of this delegate method is not needed when using AdyenSession as the session handles the presentation
    }
}

extension DropInExample {

    private func handleDisableResult(_ result: Result<DisableStoredPaymentMethodRequest.ResponseType, Error>, completion: (Bool) -> Void) {
        switch result {
        case let .failure(error):
            self.presenter?.presentAlert(with: error, retryHandler: nil)
            completion(false)
        case let .success(response):
            completion(response.response == .detailsDisabled)
        }
    }
}
