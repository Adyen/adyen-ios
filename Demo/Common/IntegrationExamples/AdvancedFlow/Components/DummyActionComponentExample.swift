//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenCheckout

internal final class DummyActionComponentExample: InitialDataAdvancedFlowProtocol {
    
    internal weak var presenter: PresenterExampleProtocol?
    
    private var checkout: Checkout?
    
    internal lazy var apiClient = ApiClientHelper.generateApiClient()
    
    // comes from demo app protocol, unused on new structure
    internal lazy var context: AdyenContext = generateContext()
    
    internal init() {}
    
    internal func start() {
        startLoading()
        
        Task { @MainActor in
            do {
                let checkout = try await createCheckout()
                let actionData = actionString.data(using: .utf8)
                let action = try JSONDecoder().decode(Action.self, from: actionData!)
                
                hideLoading()
                self.checkout = checkout
                checkout.handle(action: action)
            } catch {
                hideLoading()
                handleError(error)
            }
        }
    }
    
    private func createCheckout() async throws -> Checkout {
        let configuration = try CheckoutConfiguration(
            environment: ConfigurationConstants.componentsEnvironment,
            amount: ConfigurationConstants.current.amount,
            clientKey: ConfigurationConstants.clientKey,
            analyticsConfiguration: .init(
                isEnabled: ConfigurationConstants.current.analyticsSettings.isEnabled
            )
        ) {}
            .onAdditionalDetails { [weak self] data, handler in
                self?.callDetails(with: data, completion: handler)
            }
            .onError { [weak self] error in
                self?.dismissAndShowAlert(false, error.localizedDescription)
            }
        
        let checkout = try await Checkout.setup(
            configuration: configuration,
            presentationDelegate: self
        )
        
        return checkout
    }
    
    private func callDetails(with data: ActionComponentData, completion: PaymentsResponseHandler?) {
        let request = PaymentDetailsRequest(
            details: data.details,
            paymentData: data.paymentData,
            merchantAccount: ConfigurationConstants.current.merchantAccount
        )
        apiClient.perform(request) { result in
            switch result {
            case let .success(response):
                completion?(
                    CheckoutPaymentsResponse(
                        resultCode: response.resultCode, action: response.action
                    ))
            case let .failure(error):
                // TODO: add error handling but maybe after async callbacks
                break
            }
        }
    }
    
    private func startLoading() {
        presenter?.showLoadingIndicator()
    }
    
    @MainActor
    private func handleError(_ error: Error) {
        presenter?.presentAlert(withTitle: "Error", message: error.localizedDescription)
    }

    @MainActor
    private func hideLoading() {
        presenter?.hideLoadingIndicator()
    }
    
    private func dismissAndShowAlert(_ success: Bool, _ message: String) {
        presenter?.dismiss {
            // Payment is processed. Add your code here.
            let title = success ? "Success" : "Error"
            self.presenter?.presentAlert(withTitle: title, message: message)
        }
    }
    
    private let actionString = """
          {
            "paymentMethodType" : "pix",
            "paymentData" : "Ab02b4c0!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",
            "qrCodeData" : "TestQRCodeEMVToken",
            "type" : "qrCode"
          }
    """
}

extension DummyActionComponentExample: PresentationDelegate {
    
    func present(component: any PresentableComponent) {
        presenter?.present(viewController: component.viewController, completion: nil)
    }
}
