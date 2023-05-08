//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenCard
import AdyenComponents
import AdyenDropIn
import PassKit
import UIKit

internal final class CardComponentAdvancedFlowExample: InitialDataAdvancedFlowProtocol {
    
    internal weak var presenter: PresenterExampleProtocol?

    private var cardComponent: PresentableComponent?
    
    // MARK: - Action Handling

    private lazy var adyenActionComponent: AdyenActionComponent = {
        let handler = AdyenActionComponent(context: context)
        handler.configuration.threeDS.delegateAuthentication = ConfigurationConstants.delegatedAuthenticationConfigurations
        handler.configuration.threeDS.requestorAppURL = URL(string: ConfigurationConstants.returnUrl)
        handler.delegate = self
        handler.presentationDelegate = self
        return handler
    }()

    // MARK: - Initializers

    internal init() {}

    internal func present() {
        presenter?.showLoadingIndicator()
        requestPaymentMethods(order: nil) { [weak self] result in
            self?.presenter?.hideLoadingIndicator { [weak self] in
                
                guard let self else { return }
                
                switch result {
                case let .success(paymentMethods):
                    guard let component = self.cardComponent(from: paymentMethods) else {
                        self.presentAlert(with: IntegrationError.paymentMethodNotAvailable(paymentMethod: CardPaymentMethod.self))
                        return
                    }
                    
                    component.cardComponentDelegate = self
                    component.delegate = self
                    self.cardComponent = component
                    
                    self.present(component)
                    
                case let .failure(error):
                    self.presentAlert(with: error)
                }
            }
        }
    }

    private func cardComponent(from paymentMethods: PaymentMethods) -> CardComponent? {
        guard let paymentMethod = paymentMethods.paymentMethod(ofType: CardPaymentMethod.self) else { return nil }
        let style = FormComponentStyle()
        let config = CardComponent.Configuration(style: style)
        return CardComponent(paymentMethod: paymentMethod,
                             context: context,
                             configuration: config)
    }

    // MARK: - Presentation

    private func present(_ component: PresentableComponent) {
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

    @objc private func cancelPressed() {
        cardComponent?.cancelIfNeeded()
        presenter?.dismiss(completion: nil)
    }

    // MARK: - Payment response handling

    private func paymentResponseHandler(result: Result<PaymentsResponse, Error>) {
        switch result {
        case let .success(response):
            if let action = response.action {
                adyenActionComponent.handle(action)
            } else {
                finish(with: response)
            }
        case let .failure(error):
            finish(with: error)
        }
    }

    private func finish(with result: PaymentsResponse) {
        let success = result.resultCode == .authorised || result.resultCode == .received || result.resultCode == .pending
        let message = "\(result.resultCode.rawValue) \(result.amount?.formatted ?? "")"
        finalize(success, message)
    }

    private func finish(with error: Error) {
        let message: String
        if let componentError = (error as? ComponentError), componentError == ComponentError.cancelled {
            message = "Cancelled"
        } else {
            message = error.localizedDescription
        }
        finalize(false, message)
    }

    private func finalize(_ success: Bool, _ message: String) {
        cardComponent?.finalizeIfNeeded(with: success) { [weak self] in
            guard let self = self else { return }
            self.dismissAndShowAlert(success, message)
        }
    }
    
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

extension CardComponentAdvancedFlowExample: CardComponentDelegate {

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

extension CardComponentAdvancedFlowExample: PaymentComponentDelegate {

    internal func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        let request = PaymentsRequest(data: data)
        apiClient.perform(request) { [weak self] result in
            self?.paymentResponseHandler(result: result)
        }
    }

    internal func didFail(with error: Error, from component: PaymentComponent) {
        finish(with: error)
    }

}

extension CardComponentAdvancedFlowExample: ActionComponentDelegate {

    internal func didFail(with error: Error, from component: ActionComponent) {
        finish(with: error)
    }

    internal func didComplete(from component: ActionComponent) {
        finish(with: .received)
    }

    internal func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        (component as? PresentableComponent)?.viewController.view.isUserInteractionEnabled = false
        let request = PaymentDetailsRequest(
            details: data.details,
            paymentData: data.paymentData,
            merchantAccount: ConfigurationConstants.current.merchantAccount
        )
        apiClient.perform(request) { [weak self] result in
            self?.paymentResponseHandler(result: result)
        }
    }
}

extension CardComponentAdvancedFlowExample: PresentationDelegate {
    internal func present(component: PresentableComponent) {
        present(component)
    }
}
