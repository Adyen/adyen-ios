//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenCheckout
import UIKit

@MainActor
internal final class DropInAdvancedFlowExample: InitialDataAdvancedFlowProtocol {

    internal weak var presenter: PresenterExampleProtocol?

    private var checkout: AdvancedCheckout?
    private var dropInComponent: CheckoutDropInComponent?

    internal lazy var apiClient = ApiClientHelper.generateApiClient()
    private lazy var asyncApiClient = ApiClientHelper.generateAsyncApiClient()

    /// Comes from the demo app protocol and is unused by Checkout.
    internal var context: AdyenContext?

    internal var selectedTheme: ExampleAppTheme {
        ConfigurationConstants.current.themeSettings.theme
    }

    // MARK: - Initializers

    internal init() {}

    internal func start() {
        startLoading()

        Task { [weak self] in
            guard let self else { return }
            
            do {
                let paymentMethods = try await requestPaymentMethods(order: nil)
                let dropIn = try await dropInComponent(from: paymentMethods)
                self.dropInComponent = dropIn
                hideLoading()
                present(component: dropIn)
            } catch {
                hideLoading()
                handleError(error)
            }
        }
    }

    // MARK: - Presentation

    private func dropInComponent(from paymentMethods: PaymentMethods) async throws -> CheckoutDropInComponent {
        let configuration = try CheckoutConfiguration(
            environment: ConfigurationConstants.componentsEnvironment,
            amount: ConfigurationConstants.current.amount,
            clientKey: ConfigurationConstants.clientKey,
            analyticsConfiguration: .init(
                isEnabled: ConfigurationConstants.current.analyticsSettings.isEnabled
            )
        ) {
            ConfigurationConstants.current.cardConfiguration
            try ConfigurationConstants.current.applePayConfiguration(using: .demo)
            ConfigurationConstants.current.dropInConfiguration
            AuthenticationConfiguration()
                .requestorAppURL(ConfigurationConstants.returnUrl)
        }
        .theme(selectedTheme.theme)

        let checkout = try await Checkout.setup(
            with: paymentMethods,
            configuration: configuration,
            presentationDelegate: self
        )
        .onSubmit { [weak self] data in
            guard let self else { return .completion(resultCode: "Error") }
            return await self.callPayments(with: data)
        }
        .onAdditionalDetails { [weak self] data in
            guard let self else { return .completion(resultCode: "Error") }
            return await self.callDetails(with: data)
        }
        .onComplete { [weak self] result in
            self?.dismissAndShowAlert(
                result.resultCode.isSuccess,
                result.resultCode.rawValue
            )
        }
        .onFailure { [weak self] error in
            self?.dismissAndShowAlert(false, error.localizedDescription)
        }

        self.checkout = checkout
        return try checkout.createDropIn()
    }

    // MARK: - Payment response handling

    private func callPayments(with data: PaymentComponentData) async -> SubmitResult {
        do {
            let response = try await asyncApiClient.performAsync(PaymentsRequest(data: data))
            if let action = response.action {
                return .action(action)
            }
            return .completion(resultCode: response.resultCode.rawValue)
        } catch {
            return .completion(resultCode: "Error")
        }
    }

    private func callDetails(with data: ActionComponentData) async -> AdditionalDetailsResult {
        do {
            let request = PaymentDetailsRequest(
                details: data.details,
                paymentData: data.paymentData,
                merchantAccount: ConfigurationConstants.current.merchantAccount
            )
            let response = try await asyncApiClient.performAsync(request)
            return .completion(resultCode: response.resultCode.rawValue)
        } catch {
            return .completion(resultCode: "Error")
        }
    }

    // MARK: - Private

    private func startLoading() {
        presenter?.showLoadingIndicator()
    }

    private func handleError(_ error: Error) {
        presenter?.presentAlert(withTitle: "Error", message: error.localizedDescription)
    }

    private func hideLoading() {
        presenter?.hideLoadingIndicator()
    }

    private func present(component: CheckoutDropInComponent) {
        presenter?.present(viewController: component.viewController, completion: nil)
    }

    private func dismissAndShowAlert(_ success: Bool, _ message: String) {
        presenter?.dismiss {
            let title = success ? "Success" : "Error"
            self.presenter?.presentAlert(withTitle: title, message: message)
        }
    }
}

extension DropInAdvancedFlowExample: PresentationDelegate {

    internal func present(viewController: UIViewController) {
        presenter?.present(viewController: viewController, completion: nil)
    }
}
