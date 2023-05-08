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

    internal func present() {
        presenter?.showLoadingIndicator()
        requestInitialData { [weak self] response in
            self?.presenter?.hideLoadingIndicator { [weak self] in
                
                guard let self else { return }
                
                switch response {
                case let .success(session):
                    guard let component = self.cardComponent(from: session.sessionContext.paymentMethods) else {
                        self.presentAlert(with: IntegrationError.paymentMethodNotAvailable(paymentMethod: CardPaymentMethod.self))
                        return
                    }
                    
                    self.session = session
                    component.delegate = self.session
                    self.cardComponent = component
                    
                    self.present(component, delegate: session)
                    
                case let .failure(error):
                    self.presentAlert(with: error)
                }
            }
        }
    }

    // MARK: - Networking

    private func requestInitialData(completion: @escaping (Result<AdyenSession, Error>) -> Void) {
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

    // MARK: Card

    private func cardComponent(from paymentMethods: PaymentMethods) -> CardComponent? {
        guard let paymentMethod = paymentMethods.paymentMethod(ofType: CardPaymentMethod.self) else { return nil }
        
        let style = FormComponentStyle()
        let config = CardComponent.Configuration(style: style)
        return CardComponent(paymentMethod: paymentMethod,
                             context: context,
                             configuration: config)
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

    private func present(_ component: PresentableComponent,
                         delegate: PaymentComponentDelegate?) {
        cardComponent = component
        guard component.requiresModalPresentation else {
            presenter?.present(viewController: component.viewController, completion: nil)
            return
        }

        let navigation = UINavigationController(rootViewController: component.viewController)
        component.viewController.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .cancel,
                                                                           target: self,
                                                                           action: #selector(cancelPressed))
        presenter?.present(viewController: navigation, completion: nil)
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

    func didComplete(with resultCode: SessionPaymentResultCode, component: Component, session: AdyenSession) {
        dismissAndShowAlert(resultCode.isSuccess, resultCode.rawValue)
    }

    func didFail(with error: Error, from component: Component, session: AdyenSession) {
        dismissAndShowAlert(false, error.localizedDescription)
    }

    func didOpenExternalApplication(component: ActionComponent, session: AdyenSession) {}

}

extension CardComponentExample: PresentationDelegate {
    internal func present(component: PresentableComponent) {}
}
