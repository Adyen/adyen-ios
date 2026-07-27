//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenCheckout
import AdyenComponents
import Foundation
import UIKit

@MainActor
internal final class GenericPaymentComponentAdvancedFlow: InitialDataAdvancedFlowProtocol {

    internal weak var presenter: PresenterExampleProtocol?

    private var checkout: AdvancedCheckout?
    private var adyenComponent: CheckoutPaymentComponent?

    internal lazy var apiClient = ApiClientHelper.generateApiClient()
    private lazy var asyncApiClient = ApiClientHelper.generateAsyncApiClient()

    /// comes from demo app protocol, unused on new structure
    internal var context: AdyenContext?

    internal init() {}

    internal func start() {
        startLoading()

        Task {
            do {
                let paymentMethods = try await requestPaymentMethods(order: nil)
                let component = try await genericPaymentComponent(from: paymentMethods)
                self.adyenComponent = component
                hideLoading()

                guard !component.requiresUserInteraction else {
                    // Generic payment methods don't require user interaction
                    // For payment methods that require UI, see the card component example
                    return
                }
                component.submit()
            } catch {
                hideLoading()
                handleError(error)
            }
        }
    }

    private func genericPaymentComponent(from paymentMethods: PaymentMethods) async throws -> CheckoutPaymentComponent {
        let configuration = try CheckoutConfiguration(
            environment: ConfigurationConstants.componentsEnvironment,
            amount: ConfigurationConstants.current.amount,
            clientKey: ConfigurationConstants.clientKey,
            analyticsConfiguration: .init(
                isEnabled: ConfigurationConstants.current.analyticsSettings.isEnabled
            )
        ) {
            // No component-specific configuration needed for generic payments
        }

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

        return try checkout.createPaymentComponent(for: PaymentMethodType.ideal)
    }

    // MARK: - Backend calls

    private func callPayments(with data: PaymentComponentData) async -> SubmitResult {
        do {
            let request = PaymentsRequest(data: data)
            let response = try await asyncApiClient.performAsync(request)
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
    
    private func dismissAndShowAlert(_ success: Bool, _ message: String) {
        presenter?.dismiss {
            // Payment is processed. Add your code here.
            let title = success ? "Success" : "Error"
            self.presenter?.presentAlert(withTitle: title, message: message)
        }
    }
}

extension GenericPaymentComponentAdvancedFlow: PresentationDelegate {
    internal func present(viewController: UIViewController) {
        presenter?.present(viewController: viewController, completion: nil)
    }
}
