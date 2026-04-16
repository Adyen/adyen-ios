//
// Copyright (c) 2026 Adyen N.V.
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
    
    /// comes from demo app protocol, unused on new structure
    internal var context: AdyenContext?

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
            .onAdditionalDetails { [weak self] data in
                await self?.callDetails(with: data) ?? CheckoutPaymentsResponse(resultCode: .refused)
            }
            .onError { [weak self] error in
                self?.dismissAndShowAlert(false, error.localizedDescription)
            }
        
        return try await Checkout.setup(
            configuration: configuration,
            presentationDelegate: self
        )
    }
    
    private func callDetails(with data: ActionComponentData) async -> CheckoutPaymentsResponse {
        let request = PaymentDetailsRequest(
            details: data.details,
            paymentData: data.paymentData,
            merchantAccount: ConfigurationConstants.current.merchantAccount
        )
        return await withCheckedContinuation { continuation in
            apiClient.perform(request) { result in
                switch result {
                case let .success(response):
                    continuation.resume(returning: CheckoutPaymentsResponse(
                        resultCode: response.resultCode, action: response.action
                    ))
                case .failure:
                    continuation.resume(returning: CheckoutPaymentsResponse(resultCode: .refused))
                }
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
            "paymentData" : "paymentData",
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
