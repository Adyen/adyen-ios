//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

import Adyen
import AdyenComponents
import AdyenSession

internal final class InstantPaymentComponentExample: InitialDataFlowProtocol {

    // MARK: - Properties

    internal var session: AdyenSession?
    internal weak var presenter: PresenterExampleProtocol?
    internal var instantPaymentComponent: InstantPaymentComponent?

    internal lazy var apiClient = ApiClientHelper.generateApiClient()

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
            let component = try instantPaymentComponent(from: session)
            instantPaymentComponent = component
            presenter?.showLoadingIndicator()
            component.initiatePayment()
        } catch {
            self.presentAlert(with: error)
        }
    }

    private func instantPaymentComponent(from session: AdyenSession) throws -> InstantPaymentComponent {
        let paymentMethods = session.sessionContext.paymentMethods
        
        // Get the correct payment method from the paymentMethods object
        // In this example the first supported `InstantPaymentMethod` is chosen
        guard let paymentMethod = paymentMethods.paymentMethod(ofType: InstantPaymentMethod.self) else {
            throw IntegrationError.paymentMethodNotAvailable(paymentMethod: InstantPaymentMethod.self)
        }
        
        let component = InstantPaymentComponent(paymentMethod: paymentMethod, context: context, order: nil)
        component.delegate = session
        return component
    }

    private func present(_ component: PresentableComponent) {
        presenter?.hideLoadingIndicator()
        presenter?.present(viewController: component.viewController, completion: nil)
    }

    // MARK: - Alert handling

    internal func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        presenter?.hideLoadingIndicator()
        presenter?.presentAlert(with: error, retryHandler: retryHandler)
    }

    internal func dismissAndShowAlert(_ success: Bool, _ message: String) {
        presenter?.hideLoadingIndicator()
        presenter?.dismiss {
            // Payment is processed. Add your code here.
            let title = success ? "Success" : "Error"
            self.presenter?.presentAlert(withTitle: title, message: message)
        }
    }

}

extension InstantPaymentComponentExample: AdyenSessionDelegate {

    func didComplete(with result: AdyenSessionResult, component: Component, session: AdyenSession) {
        dismissAndShowAlert(result.resultCode.isSuccess, result.resultCode.rawValue)
    }

    func didFail(with error: Error, from component: Component, session: AdyenSession) {
        dismissAndShowAlert(false, error.localizedDescription)
    }

    func didOpenExternalApplication(component: ActionComponent, session: AdyenSession) {
        print(#function)
    }
}

extension InstantPaymentComponentExample: PresentationDelegate {
    internal func present(component: PresentableComponent) {
        presenter?.hideLoadingIndicator()
        let componentViewController = viewController(for: component)
        presenter?.present(viewController: componentViewController, completion: nil)
    }
}

private extension InstantPaymentComponentExample {

    func viewController(for component: PresentableComponent) -> UIViewController {
        guard component.requiresModalPresentation else {
            return component.viewController
        }

        let navigation = UINavigationController(rootViewController: component.viewController)
        component.viewController.navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .cancel,
                                                                          target: self,
                                                                          action: #selector(cancelPressed))
        return navigation
    }

    @objc private func cancelPressed() {
        instantPaymentComponent?.cancelIfNeeded()
        presenter?.dismiss(completion: nil)
    }
}
