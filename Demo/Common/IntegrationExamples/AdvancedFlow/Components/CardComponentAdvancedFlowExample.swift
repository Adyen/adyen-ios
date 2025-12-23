//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenCheckout
import AdyenUI
import PassKit

internal final class CardComponentAdvancedFlowExample: InitialDataAdvancedFlowProtocol {

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
                let component = try await cardComponent(from: paymentMethods)
                self.adyenComponent = component
                await hideLoading()
                await present(component: component)
            } catch {
                await hideLoading()
                await handleError(error)
            }
        }
    }
    
    // MARK: - Presentation
    
    private func cardComponent(from paymentMethods: PaymentMethods) async throws
        -> AdyenCheckoutComponent {

        let configuration = try CheckoutConfiguration(
            environment: ConfigurationConstants.componentsEnvironment,
            amount: ConfigurationConstants.current.amount,
            clientKey: ConfigurationConstants.clientKey,
            analyticsConfiguration: .init(
                isEnabled: ConfigurationConstants.current.analyticsSettings.isEnabled
            )
        ) {
            ConfigurationConstants.current.cardConfiguration
                .billingAddressMode(
                    .lookup(
                        onAddressLookup: { searchTerm in
                            await MapkitAddressLookupProvider().searchAsync(searchTerm)
                        })
                )
                .onBinChange { bin in
                    print("Here is the bin \(bin)")
                }
                .onBinLookup { brands in
                    print("Bin lookup response \(brands)")
                }
        }
        .theme(
            AdyenTheme(colors: AdyenColors(primary: .systemPurple))
                .bodyLabel(font: AdyenFonts.default.bodyEmphasized)
                .destructiveButton(
                    backgroundColor: .systemRed,
                    textColor: .white,
                    disabledBackgroundColor: .systemGray,
                    disabledTextColor: .lightGray
                )
                .cornerRadius(8.0)
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
        .onError { [weak self] error in
            self?.dismissAndShowAlert(false, error.localizedDescription)
        }

        let checkout = try await AdyenCheckout.setup(
            with: paymentMethods,
            configuration: configuration,
            presentationDelegate: self
        )

        self.adyenCheckout = checkout

        guard let cardPaymentMethod = paymentMethods.paymentMethod(ofType: CardPaymentMethod.self),
              let component = checkout.createComponent(with: cardPaymentMethod)
        else {
            throw IntegrationError.paymentMethodNotAvailable(paymentMethod: CardPaymentMethod.self)
        }

        return component
    }

    // MARK: - Payment response handling

    private func callPayments(with data: PaymentComponentData, completion: PaymentsResponseHandler?) {
        let request = PaymentsRequest(data: data)
        apiClient.perform(request) { result in
            switch result {
            case let .success(response):
                completion?(
                    CheckoutPaymentsResponse(
                        resultCode: response.resultCode, action: response.action
                    ))
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

extension CardComponentAdvancedFlowExample: PresentationDelegate {
   
    func present(component: any PresentableComponent) {
        presenter?.present(viewController: component.viewController, completion: nil)
    }
}
