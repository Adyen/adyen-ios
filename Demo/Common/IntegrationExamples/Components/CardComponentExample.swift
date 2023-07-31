//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCard
import AdyenComponents
import AdyenSession

internal final class CardComponentExample: InitialDataFlowProtocol {

    // MARK: - Properties
    
    internal weak var presenter: PresenterExampleProtocol?

    private var session: AdyenSession?
    private var cardComponent: PresentableComponent?

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
            guard let self = self else { return }
            
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
    
    // MARK: - Presentation
    
    private func presentComponent(with session: AdyenSession) {
        do {
            let component = try cardComponent(from: session)
            let componentViewController = viewController(for: component)
            presenter?.present(viewController: componentViewController, completion: nil)
            cardComponent = component
        } catch {
            self.presentAlert(with: error)
        }
    }
    
    private func cardComponent(from session: AdyenSession) throws -> CardComponent {
        let paymentMethods = session.sessionContext.paymentMethods
        
        guard let paymentMethod = paymentMethods.paymentMethod(ofType: CardPaymentMethod.self) else {
            throw IntegrationError.paymentMethodNotAvailable(paymentMethod: CardPaymentMethod.self)
        }

        let component = CardComponent(paymentMethod: paymentMethod,
                                      context: context,
                                      configuration: ConfigurationConstants.current.cardConfiguration)
        component.delegate = session
        return component
    }
    
    private func viewController(for component: PresentableComponent) -> UIViewController {
        guard component.requiresModalPresentation else {
            return component.viewController
        }
        
        let navigation = UINavigationController(rootViewController: component.viewController)
        component.viewController.navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .cancel,
                                                                          target: self,
                                                                          action: #selector(cancelPressed))
        return navigation
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

    @objc private func cancelPressed() {
        cardComponent?.cancelIfNeeded()
        presenter?.dismiss(completion: nil)
    }

}

extension CardComponentExample: CardComponentDelegate {

    func didSubmit(lastFour: String, finalBIN: String, component: CardComponent) {
        print("Card used: **** **** **** \(lastFour)")
        print("Final BIN: \(finalBIN)")
    }

    internal func didChangeBIN(_ value: String, component: CardComponent) {
        print("Current BIN: \(value)")
    }

    internal func didChangeCardBrand(_ value: [CardBrand]?, component: CardComponent) {
        print("Current card type: \((value ?? []).reduce("") { "\($0), \($1)" })")
    }
}

extension CardComponentExample: AdyenSessionDelegate {
    
    func didComplete(with result: AdyenSessionResult, component: Component, session: AdyenSession) {
        dismissAndShowAlert(result.resultCode.isSuccess, result.resultCode.rawValue)
    }

    func didFail(with error: Error, from component: Component, session: AdyenSession) {
        dismissAndShowAlert(false, error.localizedDescription)
    }

    func didOpenExternalApplication(component: ActionComponent, session: AdyenSession) {}

}

extension CardComponentExample: PresentationDelegate {
    internal func present(component: PresentableComponent) {
        // The implementation of this delegate method is not needed when using AdyenSession
    }
}
