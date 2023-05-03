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

    internal var session: AdyenSession?
    internal var cardComponent: PresentableComponent?
    internal weak var presenter: PresenterExampleProtocol?

    // MARK: - Initializers

    internal init() {}

    // MARK: - Networking

    internal func requestInitialData(completion: ((PaymentMethods?, Error?) -> Void)?) {
        requestAdyenSessionConfiguration { [weak self] adyenSessionConfig, errorResponse in
            guard let self = self else {
                return
            }
            guard let config = adyenSessionConfig else {
                return
            }
            AdyenSession.initialize(with: config,
                                    delegate: self,
                                    presentationDelegate: self) { [weak self] result in
                switch result {
                case let .success(session):
                    self?.session = session
                case let .failure(errorResponse):
                    self?.presentAlert(with: errorResponse)
                }
            }
        }
    }

    // MARK: Card

    internal func present() {
        guard let component = cardComponent(from: session?.sessionContext.paymentMethods) else { return }
        cardComponent = component
        component.delegate = session
        present(component, delegate: session)
    }

    internal func cardComponent(from paymentMethods: PaymentMethods?) -> CardComponent? {
        guard let paymentMethods = paymentMethods,
              let paymentMethod = paymentMethods.paymentMethod(ofType: CardPaymentMethod.self) else { return nil }
        let style = FormComponentStyle()
        let config = CardComponent.Configuration(style: style)
        return CardComponent(paymentMethod: paymentMethod,
                             context: context,
                             configuration: config)
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
        requestInitialData() { _, _ in }
        dismissAndShowAlert(resultCode.isSuccess, resultCode.rawValue)
    }

    func didFail(with error: Error, from component: Component, session: AdyenSession) {
        requestInitialData() { _, _ in }
        dismissAndShowAlert(false, error.localizedDescription)
    }

    func didOpenExternalApplication(component: ActionComponent, session: AdyenSession) {}

}

extension CardComponentExample: PresentationDelegate {
    internal func present(component: PresentableComponent) {}
}
