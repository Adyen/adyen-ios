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
internal final class DropInExample: InitialDataFlowProtocol {

    // MARK: - Properties

    internal weak var presenter: PresenterExampleProtocol?

    private var checkout: SessionCheckout?
    private var dropInComponent: CheckoutDropInComponent?

    internal lazy var apiClient = ApiClientHelper.generateApiClient()

    /// Comes from the demo app protocol and is unused by Checkout.
    internal var context: AdyenContext?

    // MARK: - Initializers

    internal init() {}

    internal func start() {
        startLoading()

        Task { [weak self] in
            guard let self else { return }
            
            do {
                let sessionResponse = try await requestSessionInitialInfo()
                let dropIn = try await self.dropInComponent(from: sessionResponse)
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

    private func dropInComponent(from sessionResponse: SessionResponse) async throws -> CheckoutDropInComponent {
        let configuration = try CheckoutConfiguration(
            environment: ConfigurationConstants.componentsEnvironment,
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
        .theme(ConfigurationConstants.current.themeSettings.theme.theme)

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
        return try checkout.createDropIn()
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

extension DropInExample: PresentationDelegate {

    internal func present(viewController: UIViewController) {
        presenter?.present(viewController: viewController, completion: nil)
    }
}
