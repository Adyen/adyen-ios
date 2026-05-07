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

@MainActor
internal final class BLIKComponentAdvancedFlowExample: InitialDataAdvancedFlowProtocol {

    internal weak var presenter: PresenterExampleProtocol?

    private var checkout: Checkout?
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
                let component = try await blikComponent(from: paymentMethods)
                self.adyenComponent = component
                hideLoading()
                present(component: component)
            } catch {
                hideLoading()
                handleError(error)
            }
        }
    }

    private func blikComponent(from paymentMethods: PaymentMethods) async throws
        -> CheckoutPaymentComponent {

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
        .theme(
            CheckoutTheme(colors: AdyenColors(primary: .systemBlue))
                .bodyLabel(font: AdyenFonts.default.bodyEmphasized)
                .destructiveButton(
                    backgroundColor: .systemRed,
                    textColor: .white,
                    disabledBackgroundColor: .systemGray,
                    disabledTextColor: .lightGray
                )
                .cornerRadius(8.0)
        )
        .onSubmit { [weak self] data in
            guard let self else { throw CancellationError() }
            return try await self.callPayments(with: data)
        }
        .onAdditionalDetails { [weak self] data in
            guard let self else { throw CancellationError() }
            return try await self.callDetails(with: data)
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
            with: paymentMethods,
            configuration: configuration,
            presentationDelegate: self
        )

        self.checkout = checkout

        return try checkout.createPaymentComponent(for: .blik)
    }

    // MARK: - Backend calls

    private func callPayments(with data: PaymentComponentData) async throws -> SubmitResult {
        let request = PaymentsRequest(data: data)
        let response = try await asyncApiClient.performAsync(request)
        if let action = response.action {
            return .action(action)
        }
        return .completion(resultCode: response.resultCode.rawValue)
    }

    private func callDetails(with data: ActionComponentData) async throws -> AdditionalDetailsResult {
        let request = PaymentDetailsRequest(
            details: data.details,
            paymentData: data.paymentData,
            merchantAccount: ConfigurationConstants.current.merchantAccount
        )
        let response = try await asyncApiClient.performAsync(request)
        return .completion(resultCode: response.resultCode.rawValue)
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

    private func present(component: CheckoutPaymentComponent) {
        presenter?.present(viewController: viewController(for: component), completion: nil)
    }

    private func dismissAndShowAlert(_ success: Bool, _ message: String) {
        presenter?.dismiss {
            // Payment is processed. Add your code here.
            let title = success ? "Success" : "Error"
            self.presenter?.presentAlert(withTitle: title, message: message)
        }
    }

    private func viewController(for component: CheckoutPaymentComponent) -> UIViewController {
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
