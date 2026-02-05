//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenComponents
import AdyenSession
import Foundation

internal final class InstantPaymentComponentExample: InitialDataFlowProtocol {

    // MARK: - Properties

    internal var session: Session?
    internal weak var presenter: PresenterExampleProtocol?
    internal var instantPaymentComponent: InstantPaymentComponent?

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

    internal func loadSession(completion: @escaping (Result<Session, Error>) -> Void) {
        requestSessionInitialInfo { [weak self] response in
            guard let self else { return }
            switch response {
            case let .success(model):
//                AdyenSession.initialize(
//                    with: configuration,
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

    // MARK: Presentation

    internal func presentComponent(with session: Session) {
        do {
            let component = try instantPaymentComponent(from: session)
            instantPaymentComponent = component
            presenter?.showLoadingIndicator()
            component.initiatePayment()
        } catch {
            self.presentAlert(with: error)
        }
    }

    private func instantPaymentComponent(from session: Session) throws -> InstantPaymentComponent {
        let paymentMethods = session.state.paymentMethods
        
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

extension InstantPaymentComponentExample: SessionDelegate {

    func didComplete(with result: CheckoutResult, component: Component, session: Session) {
        dismissAndShowAlert(result.resultCode.isSuccess, result.resultCode.rawValue)
    }

    func didFail(with error: Error, from component: Component, session: Session) {
        dismissAndShowAlert(false, error.localizedDescription)
    }

    func didOpenExternalApplication(component: ActionComponent, session: Session) {
        print(#function)
    }
}

extension InstantPaymentComponentExample: PresentationDelegate {
    internal func present(component: PresentableComponent) {
        presenter?.hideLoadingIndicator()
        let componentViewController = component.viewController
        componentViewController.navigationItem.leftBarButtonItem = .init(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelPressed)
        )
        presenter?.present(viewController: componentViewController, completion: nil)
    }
}

private extension InstantPaymentComponentExample {

    @objc private func cancelPressed() {
        instantPaymentComponent?.cancel()
        presenter?.dismiss(completion: nil)
    }
}
