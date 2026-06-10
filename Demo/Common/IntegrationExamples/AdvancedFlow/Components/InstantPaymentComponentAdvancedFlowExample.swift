//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenComponents
import Foundation

internal final class InstantPaymentComponentAdvancedFlow: InitialDataAdvancedFlowProtocol {

    // MARK: - Properties

    internal var instantPaymentComponent: InstantPaymentComponent?

    internal weak var presenter: PresenterExampleProtocol?
    
    internal lazy var apiClient = ApiClientHelper.generateApiClient()
    
    /// comes from demo app protocol, unused on new structure
    internal var context: AdyenContext?

    // MARK: - Action Handling

    private lazy var actionComponent: CheckoutActionComponent = {
        guard let context else {
            fatalError("Context not initialized")
        }
        let handler = CheckoutActionComponent(context: context)
        handler.delegate = self
        handler.presentationDelegate = self
        return handler
    }()

    // MARK: - Initializers

    internal init() {}

    internal func start() {
        presenter?.showLoadingIndicator()
        Task {
            do {
                try await initializeExampleAppAdyenContext()
                requestPaymentMethods(order: nil) { [weak self] result in
                    guard let self else { return }

                    self.presenter?.hideLoadingIndicator()

                    switch result {
                    case let .success(paymentMethods):
                        self.presentComponent(with: paymentMethods)

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
    
    // MARK: - Presentation
    
    private func presentComponent(with paymentMethods: PaymentMethods) {
        do {
            let component = try instantPaymentComponent(from: paymentMethods)
            instantPaymentComponent = component
            component.submit()
        } catch {
            self.presentAlert(with: error)
        }
    }
    
    private func instantPaymentComponent(from paymentMethods: PaymentMethods) throws -> InstantPaymentComponent {
        
        // Get the correct payment method from the paymentMethods object
        // In this example the first supported `InstantPaymentMethod` is chosen
        guard let paymentMethod = paymentMethods.paymentMethod(ofType: InstantPaymentMethod.self) else {
            throw IntegrationError.paymentMethodNotAvailable(paymentMethod: InstantPaymentMethod.self)
        }
        guard let context else {
            fatalError("AdyenContext not initialized")
        }
        
        return InstantPaymentComponent(paymentMethod: paymentMethod, context: context, order: nil)
    }

    // MARK: - Payment response handling

    private func paymentResponseHandler(result: Result<PaymentsResponse, Error>) {
        switch result {
        case let .success(response):
            if let action = response.action {
                actionComponent.handle(action)
            } else {
                finish(with: response)
            }
        case let .failure(error):
            finish(with: error)
        }
    }

    private func finish(with result: PaymentsResponse) {
        let success = result.isAccepted
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
        instantPaymentComponent?.finalizeIfNeeded(with: success) { [weak self] in
            guard let self else { return }
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

extension InstantPaymentComponentAdvancedFlow: PaymentComponentDelegate {

    internal func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        presenter?.showLoadingIndicator()
        let request = PaymentsRequest(data: data)
        apiClient.perform(request) { [weak self] result in
            self?.presenter?.hideLoadingIndicator()
            self?.paymentResponseHandler(result: result)
        }
    }

    internal func didFail(with error: Error, from component: PaymentComponent) {
        finish(with: error)
    }

}

extension InstantPaymentComponentAdvancedFlow: ActionComponentDelegate {

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

extension InstantPaymentComponentAdvancedFlow: PresentationDelegate {
    internal func present(component: PresentableComponent) {
        let componentViewController = component.viewController
        componentViewController.navigationItem.leftBarButtonItem = .init(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelPressed)
        )
        presenter?.present(viewController: componentViewController, completion: nil)
    }
}

private extension InstantPaymentComponentAdvancedFlow {

    @objc private func cancelPressed() {
        instantPaymentComponent?.cancel()
        presenter?.dismiss(completion: nil)
    }
}
