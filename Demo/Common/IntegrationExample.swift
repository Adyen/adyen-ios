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
import AdyenNetworking
import AdyenSession
import UIKit

internal protocol Presenter: AnyObject {

    func present(viewController: UIViewController, completion: (() -> Void)?)

    func dismiss(completion: (() -> Void)?)

    func presentAlert(withTitle title: String, message: String?)

    func presentAlert(with error: Error, retryHandler: (() -> Void)?)
}

internal final class IntegrationExample: APIClientAware {

    internal var paymentMethods: PaymentMethods?
    internal var currentComponent: PresentableComponent?
    internal var sessionPaymentMethods: PaymentMethods?

    internal weak var presenter: Presenter?

    internal var context: AdyenContext {
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = true
        return AdyenContext(apiContext: ConfigurationConstants.apiContext,
                            payment: ConfigurationConstants.current.payment,
                            analyticsConfiguration: analyticsConfiguration)
    }

    internal var session: AdyenSession?
    
    internal lazy var palApiClient: APIClientProtocol = {
        let context = DemoAPIContext(environment: ConfigurationConstants.classicAPIEnvironment)
        return DefaultAPIClient(apiContext: context)
    }()

    // MARK: - Action Handling for Components

    internal lazy var adyenActionComponent: AdyenActionComponent = {
        let handler = AdyenActionComponent(context: context)
        handler.configuration.threeDS.delegateAuthentication = ConfigurationConstants.delegatedAuthenticationConfigurations
        handler.configuration.threeDS.requestorAppURL = URL(string: ConfigurationConstants.returnUrl)
        handler.delegate = self
        handler.presentationDelegate = self
        return handler
    }()

    // MARK: - Initializers

    internal init() {}

    // MARK: - Networking
    
    internal func requestInitialData() {
        requestPaymentMethods()
        setupSession()
    }

    internal func requestPaymentMethods(order: PartialPaymentOrder? = nil,
                                        completion: ((PaymentMethods) -> Void)? = nil) {
        let request = PaymentMethodsRequest(order: order)
        apiClient.perform(request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(response):
                self.paymentMethods = response.paymentMethods
                completion?(response.paymentMethods)
            case let .failure(error):
                self.presentAlert(with: error) { [weak self] in
                    self?.requestPaymentMethods(order: order, completion: completion)
                }
            }
        }
    }
    
    internal func setupSession() {
        let request = SessionRequest()
        apiClient.perform(request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(response):
                self.initializeSession(with: response.sessionId, data: response.sessionData)
            case let .failure(error):
                self.presentAlert(with: error) { [weak self] in
                    self?.setupSession()
                }
            }
        }
    }
    
    private func initializeSession(with sessionId: String, data: String) {
        let configuration = AdyenSession.Configuration(
            sessionIdentifier: sessionId,
            initialSessionData: data,
            context: context,
            actionComponent: .init(
                threeDS: .init(
                    requestorAppURL: URL(string: ConfigurationConstants.returnUrl),
                    delegateAuthentication: ConfigurationConstants.delegatedAuthenticationConfigurations
                )
            )
        )
        AdyenSession.initialize(with: configuration, delegate: self, presentationDelegate: self) { [weak self] result in
            switch result {
            case let .success(session):
                self?.session = session
                self?.sessionPaymentMethods = session.sessionContext.paymentMethods
            case let .failure(error):
                self?.presentAlert(with: error)
            }
        }
    }

    internal func finish(with result: PaymentsResponse) {
        let success = result.resultCode == .authorised || result.resultCode == .received || result.resultCode == .pending
        let message = "\(result.resultCode.rawValue) \(result.amount?.formatted ?? "")"
        finalize(success, message)
    }

    internal func finish(with error: Error) {
        let message: String
        if let componentError = (error as? ComponentError), componentError == ComponentError.cancelled {
            message = "Cancelled"
        } else {
            message = error.localizedDescription
        }
        finalize(false, message)
    }

    internal func dismissAndShowAlert(_ success: Bool, _ message: String) {
        presenter?.dismiss {
            // Payment is processed. Add your code here.
            let title = success ? "Success" : "Error"
            self.presenter?.presentAlert(withTitle: title, message: message)
        }
    }

    private func finalize(_ success: Bool, _ message: String) {
        currentComponent?.finalizeIfNeeded(with: success) { [weak self] in
            guard let self = self else { return }
            self.dismissAndShowAlert(success, message)
        }
    }

    internal func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        presenter?.presentAlert(with: error, retryHandler: retryHandler)
    }

    // MARK: - BACS Direct Debit Component

    internal var bacsDirectDebitPresenter: BACSDirectDebitPresentationDelegate?
}
