//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenCard
import AdyenCheckout
import AdyenComponents
import AdyenDropIn
import AdyenNetworking
import AdyenSession
import UIKit

internal final class DropInExample: InitialDataFlowProtocol {

    // MARK: - Properties

    internal weak var presenter: PresenterExampleProtocol?

    private var session: Session?
    private var dropInComponent: DropInComponent?
    
    internal lazy var apiClient = ApiClientHelper.generateApiClient()
    
    internal var context: AdyenContext?

    // MARK: - Initializers

    internal init() {}

    internal func start() {
        presenter?.showLoadingIndicator()
        Task {
            do {
                try await initializeExampleAppAdyenContext()
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

            } catch {
                self.presenter?.hideLoadingIndicator()
                self.presentAlert(with: error)
            }

        }
    }
    
    // MARK: - Networking

    private func loadSession(completion: @escaping (Result<Session, Error>) -> Void) {
        requestSessionInitialInfo { [weak self] response in
            guard let self else { return }
            
            switch response {
            case let .success(model):
//                Session.initialize(
//                    with: config,
//                    delegate: self,
//                    presentationDelegate: self,
//                    completion: completion
//                )
                break
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Presentation
    
    private func presentComponent(with session: Session) {
        do {
            let dropIn = try dropInComponent(from: session)
            presenter?.present(viewController: dropIn.viewController, completion: nil)
            dropInComponent = dropIn
        } catch {
            presentAlert(with: error)
        }
    }

    private func dropInComponent(from session: Session) throws -> DropInComponent {
        guard let context else {
            fatalError("AdyenContext is not initialized")
        }

        let configuration = try CheckoutConfiguration(
            environment: ConfigurationConstants.componentsEnvironment,
            amount: ConfigurationConstants.current.amount,
            clientKey: ConfigurationConstants.clientKey,
            analyticsConfiguration: ConfigurationConstants.current.analyticsConfiguration
        ) {
            ConfigurationConstants.current.cardConfiguration
            try ConfigurationConstants.current.applePayConfiguration(using: .demo)
            ConfigurationConstants.current.dropInConfiguration
        }
        .theme(ConfigurationConstants.current.themeSettings.theme.theme)

        // TODO: intermediate dropin creation for demo app, to be replaced next
        return DropInComponent(
            paymentMethods: session.state.paymentMethods,
            context: context,
            configuration: configuration.dropInConfiguration,
            actionComponentConfiguration: ConfigurationConstants.current.dropInActionComponentConfiguration,
            paymentComponentBuilder: { paymentMethod in
                try CheckoutComponentBuilder.build(
                    forAnyPaymentMethod: paymentMethod,
                    configuration: configuration,
                    context: context
                )
            },
            title: ConfigurationConstants.appName
        )

        // TODO: Migrate to Checkout — Session no longer conforms to delegate protocols in v6.
        // component.delegate = session
        // component.storedPaymentMethodsDelegate = session
        // component.partialPaymentDelegate = session
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

// TODO: Migrate to Checkout API — SessionDelegate has been removed in v6.

extension DropInExample: PresentationDelegate {
    internal func present(viewController: UIViewController) {
        // The implementation of this delegate method is not needed when using Session as the session handles the presentation
    }
}
