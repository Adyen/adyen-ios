//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenCheckout

/// Standalone example that presents a Boleto `VoucherView` without going through a full payment flow.
///
/// It decodes a hardcoded voucher `Action` and hands it to an `ActionOnlyCheckout`, which internally
/// routes it to the `VoucherComponent`. This is useful for quickly iterating on the voucher UI.
internal final class VoucherActionExample: InitialDataAdvancedFlowProtocol {

    internal weak var presenter: PresenterExampleProtocol?

    private var checkout: ActionOnlyCheckout?

    internal lazy var apiClient = ApiClientHelper.generateApiClient()
    private lazy var asyncApiClient = ApiClientHelper.generateAsyncApiClient()
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

    private func createCheckout() async throws -> ActionOnlyCheckout {
        let configuration = try CheckoutConfiguration(
            environment: ConfigurationConstants.componentsEnvironment,
            amount: ConfigurationConstants.current.amount,
            clientKey: ConfigurationConstants.clientKey,
            analyticsConfiguration: .init(
                isEnabled: ConfigurationConstants.current.analyticsSettings.isEnabled
            )
        ) {}

        return try await Checkout.setup(
            configuration: configuration,
            presentationDelegate: self
        )
        .onAdditionalDetails { [weak self] data in
            guard let self else { return .completion(resultCode: "Error") }
            return await self.callDetails(with: data)
        }
        .onFailure { [weak self] error in
            self?.dismissAndShowAlert(false, error.localizedDescription)
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
            let title = success ? "Success" : "Error"
            self.presenter?.presentAlert(withTitle: title, message: message)
        }
    }

    private let actionString = """
          {
            "type" : "voucher",
            "paymentMethodType" : "boletobancario_santander",
            "totalAmount" : {
              "currency" : "BRL",
              "value" : 1
            },
            "reference" : "1234.5678.9012.3456.7890",
            "expiresAt" : "2027-12-31T23:59:59",
            "downloadUrl" : "https://adyen.com"
          }
    """
}

extension VoucherActionExample: PresentationDelegate {

    func present(viewController: UIViewController) {
        // Wrap in a navigation controller with a cancel button so the action can be dismissed
        // when testing it in isolation (the standalone Checkout flow adds no navigation chrome).
        let navigationController = UINavigationController(rootViewController: viewController)
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .cancel,
            primaryAction: UIAction { [weak self] _ in
                self?.presenter?.dismiss(completion: nil)
            }
        )
        presenter?.present(viewController: navigationController, completion: nil)
    }
}
