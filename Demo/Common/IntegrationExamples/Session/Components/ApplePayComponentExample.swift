//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCheckout
import AdyenComponents
import Contacts
import PassKit

@MainActor
internal final class ApplePayComponentExample: InitialDataFlowProtocol {

    internal weak var presenter: PresenterExampleProtocol?

    private var checkout: Checkout?
    private var adyenComponent: CheckoutPaymentComponent?

    internal lazy var apiClient = ApiClientHelper.generateApiClient()

    /// comes from demo app protocol, unused on new structure
    internal var context: AdyenContext?

    internal init() {}

    internal func start() {
        startLoading()

        Task {
            do {
                let sessionResponse = try await requestSessionInitialInfo()
                let component = try await applePayComponent(from: sessionResponse)
                self.adyenComponent = component
                hideLoading()
                present(component: component)
            } catch {
                hideLoading()
                handleError(error)
            }
        }
    }

    private func applePayComponent(from sessionResponse: SessionResponse) async throws -> CheckoutPaymentComponent {
        let configuration = try CheckoutConfiguration(
            environment: ConfigurationConstants.componentsEnvironment,
            amount: ConfigurationConstants.current.amount,
            clientKey: ConfigurationConstants.clientKey,
            analyticsConfiguration: .init(
                isEnabled: ConfigurationConstants.current.analyticsSettings.isEnabled
            )
        ) {
            try ConfigurationConstants.current
                .applePayConfiguration(using: .demo)
                .onAuthorize { _ in
                    if ConfigurationConstants.current.applePaySettings.didAuthorizeSuccessful {
                        return PKPaymentAuthorizationResult(status: .success, errors: nil)
                    } else {
                        let postalCodeError = PKPaymentRequest.paymentShippingAddressInvalidError(
                            withKey: CNPostalAddressPostalCodeKey,
                            localizedDescription: "Wrong postal code"
                        )
                        return PKPaymentAuthorizationResult(status: .failure, errors: [postalCodeError])
                    }
                }
        }
        .onComplete { [weak self] result in
            self?.dismissAndShowAlert(
                result.resultCode.isSuccess,
                result.resultCode.rawValue
            )
        }
        .onError { [weak self] error in
            self?.dismissAndShowAlert(false, error.localizedDescription)
        }

        let checkout = try await Checkout.setup(
            with: sessionResponse,
            configuration: configuration,
            presentationDelegate: self
        )

        self.checkout = checkout

        return try checkout.createPaymentComponent(for: .applePay)
    }

    private func startLoading() {
        presenter?.showLoadingIndicator()
    }

    private func handleError(_ error: Error) {
        presenter?.presentAlert(withTitle: "Error", message: error.localizedDescription)
    }

    private func hideLoading() {
        presenter?.hideLoadingIndicator()
    }

    private func present(component: CheckoutPaymentComponent) {
        guard let viewController = component.viewController else {
            handleError(IntegrationError.paymentMethodNotAvailable(paymentMethod: ApplePayPaymentMethod.self))
            return
        }
        // Apple Pay's PassKit sheet is presented as-is; no navigation wrapper.
        presenter?.present(viewController: viewController, completion: nil)
    }

    private func dismissAndShowAlert(_ success: Bool, _ message: String) {
        presenter?.dismiss {
            // Payment is processed. Add your code here.
            let title = success ? "Success" : "Error"
            self.presenter?.presentAlert(withTitle: title, message: message)
        }
    }
}

extension ApplePayComponentExample: PresentationDelegate {

    func present(component: any PresentableComponent) {
        presenter?.present(viewController: component.viewController, completion: nil)
    }
}
