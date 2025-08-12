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
        presenter?.showLoadingIndicator()
        requestPaymentMethods(order: nil) { [weak self] result in
            guard let self else { return }

            do {
                switch result {
                case let .success(paymentMethods):
                    try self.presentBlik(from: paymentMethods)
                case let .failure(error):
                    throw error
                }
            } catch {
                self.presenter?.hideLoadingIndicator()
                self.presenter?.presentAlert(withTitle: "Error", message: error.localizedDescription)
            }
        }
    }

    private func presentBlik(from paymentMethods: PaymentMethods) throws {
        guard let blikPaymentMethod = paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self) else { throw IntegrationError.paymentMethodNotAvailable(paymentMethod: BLIKPaymentMethod.self) }

        let configuration = try CheckoutConfiguration(
            environment: ConfigurationConstants.componentsEnvironment,
            amount: ConfigurationConstants.current.amount,
            clientKey: ConfigurationConstants.clientKey,
            analyticsConfiguration: .init(
                isEnabled: ConfigurationConstants.current.analyticsSettings.isEnabled
            )
        ) {
            BLIKComponentConfiguration()
                .showsSubmitButton(false)
        }
        .theme(AdyenTheme
            .label(LabelStyle.default
                .font(FontStyle.default.body)
                .color(ColorScheme.default.primary)
            ))
        .onSubmit { [weak self] data, handler in
            self?.callPayments(with: data, completion: handler)
        }
        .onAdditionalDetails { [weak self] data, handler in
            self?.callDetails(with: data, completion: handler)
        }
        .onComplete { [weak self] result in
            self?.presenter?.dismiss {
                self?.presenter?.presentAlert(withTitle: "Result Code", message: result.resultCode.rawValue)
            }
        }

        AdyenCheckout.setup(
            with: paymentMethods,
            configuration: configuration,
            presentationDelegate: self
        ) { [weak self] result in
            guard let self else { return }

            self.presenter?.hideLoadingIndicator()

            switch result {
            case let .success(checkout):
                self.adyenCheckout = checkout
                guard let component = checkout.createComponent(with: blikPaymentMethod) else {
                    print("component not found")
                    return
                }
                self.adyenComponent = component
                self.presenter?.present(viewController: viewController(for: component), completion: nil)
            case let .failure(error):
                print("failed to create adyen checkout \(error)")
            }
        }

        // add all the config options to settings? like show submit button
    }

    // MARK: - Backend calls

    private func callPayments(with data: PaymentComponentData, completion: PaymentsResponseHandler?) {
        let request = PaymentsRequest(data: data)
        apiClient.perform(request) { [weak self] result in
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
        apiClient.perform(request) { [weak self] result in
            switch result {
            case let .success(response):
                completion?(CheckoutPaymentsResponse(resultCode: response.resultCode, action: response.action))
            case let .failure(error):
                // TODO: add error handling
                break
            }
        }
    }

    // MARK: - Private

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
