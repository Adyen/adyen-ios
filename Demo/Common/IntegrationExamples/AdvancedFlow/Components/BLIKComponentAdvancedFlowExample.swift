//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenCheckout
import AdyenComponents
import AdyenUI

internal final class BLIKComponentAdvancedFlowExample: InitialDataAdvancedFlowProtocol {

    internal weak var presenter: PresenterExampleProtocol?
    
    private var adyenCheckout: AdyenCheckout?
    private var adyenComponent: AdyenCheckoutComponent?
    
    internal lazy var apiClient = ApiClientHelper.generateApiClient()
    
    // comes from demo app protocol, unused on new structure
    internal lazy var context: AdyenContext = generateContext()
    
    internal init() {}
    
    internal func start() {
        startLoading()
        
        Task {
            do {
                let paymentMethods = try await requestPaymentMethods(order: nil)
                let component = try await blikComponent(from: paymentMethods)
                self.adyenComponent = component
                await hideLoading()
                await present(component: component)
            } catch {
                await hideLoading()
                await handleError(error)
            }
        }
    }
    
    private func blikComponent(from paymentMethods: PaymentMethods) async throws -> AdyenCheckoutComponent {
        
        let configuration = try CheckoutConfiguration(
            environment: ConfigurationConstants.componentsEnvironment,
            amount: ConfigurationConstants.current.amount,
            clientKey: ConfigurationConstants.clientKey,
            analyticsConfiguration: .init(
                isEnabled: ConfigurationConstants.current.analyticsSettings.isEnabled
            )
        ) {
            BLIKComponentConfiguration()
        }
        // Providing theme with custom label and button
        .theme(
            label: AdyenLabelStyle(
                font: AdyenFonts.default.body,
                color: AdyenColorScheme.default.primary,
                textAlignment: .natural
            ),
            button: AdyenButtonStyles(colorScheme: .default)
        )
        // Providing theme with only custom label
        .theme(label: AdyenLabelStyle()
            .font(AdyenFonts.default.body)
        )
        // Providing theme with only custom button
        .theme(button: AdyenButtonStyles(
            colorScheme: AdyenColorScheme(background: .red))
        )
        // Providing theme with label and button name
        .theme(
            label: AdyenLabelStyle()
                .font(AdyenFonts.default.body)
                .color(AdyenColorScheme.default.textOnPrimary),
            button: AdyenButtonStyles()
        )
        // Providing theme with only custom label
        .theme(label: AdyenLabelStyle()
            .font(AdyenFonts.default.body)
            .color(AdyenColorScheme.default.primary)
        )
        .onSubmit { [weak self] data, handler in
            self?.callPayments(with: data, completion: handler)
        }
        .onAdditionalDetails { [weak self] data, handler in
            self?.callDetails(with: data, completion: handler)
        }
        .onComplete { [weak self] result in
            self?.dismissAndShowAlert(
                result.resultCode.isSuccess,
                result.resultCode.rawValue
            )
        }
        
        let checkout = try await AdyenCheckout.setup(with: paymentMethods, configuration: configuration, presentationDelegate: self)
        
        self.adyenCheckout = checkout
        
        guard let blikPaymentMethod = paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self),
              let component = checkout.createComponent(with: blikPaymentMethod) else {
            throw IntegrationError.paymentMethodNotAvailable(paymentMethod: BLIKPaymentMethod.self)
        }
        
        return component
    }
    
    // MARK: - Backend calls
    
    private func callPayments(with data: PaymentComponentData, completion: PaymentsResponseHandler?) {
        let request = PaymentsRequest(data: data)
        apiClient.perform(request) { result in
            switch result {
            case let .success(response):
                completion?(CheckoutPaymentsResponse(resultCode: response.resultCode, action: response.action))
            case let .failure(error):
                // TODO: change last parameter to accept error as well Result<CheckoutCallbackResult, Error>
                break
            }
        }
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
                completion?(CheckoutPaymentsResponse(resultCode: response.resultCode, action: response.action))
            case let .failure(error):
                // TODO: add error handling but maybe after async callbacks
                break
            }
        }
    }
    
    // MARK: - Private
    
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
    
    @MainActor
    private func present(component: AdyenCheckoutComponent) {
        presenter?.present(viewController: viewController(for: component), completion: nil)
    }
    
    private func dismissAndShowAlert(_ success: Bool, _ message: String) {
        presenter?.dismiss {
            // Payment is processed. Add your code here.
            let title = success ? "Success" : "Error"
            self.presenter?.presentAlert(withTitle: title, message: message)
        }
    }
    
    private func viewController(for component: AdyenCheckoutComponent) -> UIViewController {
        let navigation = UINavigationController(rootViewController: component.viewController!)
        component.viewController?.navigationItem.leftBarButtonItem = .init(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelPressed)
        )
        return navigation
    }
    
    @objc private func cancelPressed() {
        // TODO: component cancellation?
//        component?.cancelIfNeeded()
        presenter?.dismiss(completion: nil)
    }
}

extension BLIKComponentAdvancedFlowExample: PresentationDelegate {
    
    func present(component: any PresentableComponent) {
        presenter?.present(viewController: component.viewController, completion: nil)
    }
}
