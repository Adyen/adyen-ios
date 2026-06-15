//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCheckout
import AdyenComponents
import Foundation

@MainActor
internal final class InstantPaymentComponentExample: InitialDataFlowProtocol {

    internal weak var presenter: PresenterExampleProtocol?

    private var checkout: SessionCheckout?
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
                let sessionResponse = try await requestSessionInitialInfo()
                let component = try await instantPaymentComponent(from: sessionResponse)
                self.adyenComponent = component
                hideLoading()

                guard !component.requiresUserInteraction else {
                    // Instant payment methods don't require user interaction
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

    private func instantPaymentComponent(from sessionResponse: SessionResponse) async throws -> CheckoutPaymentComponent {
        let configuration = try CheckoutConfiguration(
            environment: ConfigurationConstants.componentsEnvironment,
            amount: ConfigurationConstants.current.amount,
            clientKey: ConfigurationConstants.clientKey,
            analyticsConfiguration: .init(
                isEnabled: ConfigurationConstants.current.analyticsSettings.isEnabled
            )
        ) {
            // No component-specific configuration needed for instant payments
        }

        let checkout = try await Checkout.setup(
            with: sessionResponse,
            configuration: configuration,
            presentationDelegate: self
        )
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

extension InstantPaymentComponentExample: PresentationDelegate {

    func present(component: any PresentableComponent) {
        presenter?.present(viewController: component.viewController, completion: nil)
    }
}
