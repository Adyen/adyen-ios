//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

import Adyen
import AdyenActions
import AdyenComponents

internal final class InstantPaymentComponentAdvancedFlow: InitialDataAdvancedFlowProtocol {

    // MARK: - Properties

    internal var instantPaymentComponent: InstantPaymentComponent?

    internal weak var presenter: PresenterExampleProtocol?
    
    internal lazy var apiClient = ApiClientHelper.generateApiClient()
    
    internal lazy var context: AdyenContext = generateContext()

    // MARK: - Action Handling

    private lazy var adyenActionComponent: AdyenActionComponent = {
        let handler = AdyenActionComponent(context: context)
        handler.delegate = self
        handler.presentationDelegate = self
        return handler
    }()

    // MARK: - Initializers

    internal init() {}

    internal func start() {
        presenter?.showLoadingIndicator()
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
    }
    
    // MARK: - Presentation
    
    private func presentComponent(with paymentMethods: PaymentMethods) {
        do {
            let component = try instantPaymentComponent(from: paymentMethods)
            instantPaymentComponent = component
            component.initiatePayment()
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
        
        let component = InstantPaymentComponent(paymentMethod: paymentMethod, context: context, order: nil)
        component.delegate = self
        return component
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
        let componentViewController = viewController(for: component)
        presenter?.present(viewController: componentViewController, completion: nil)
    }
}

private extension InstantPaymentComponentAdvancedFlow {
    
    private func viewController(for component: PresentableComponent) -> UIViewController {
        guard component.requiresModalPresentation else {
            return component.viewController
        }

        let navigation = UINavigationController(rootViewController: component.viewController)
        component.viewController.navigationItem.leftBarButtonItem = .init(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelPressed)
        )
        return navigation
    }

    @objc private func cancelPressed() {
        instantPaymentComponent?.cancelIfNeeded()
        presenter?.dismiss(completion: nil)
    }
}
