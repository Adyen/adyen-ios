//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenCheckout
import AdyenComponents
import Contacts
import PassKit

@MainActor
internal final class ApplePayComponentAdvancedFlowExample: InitialDataAdvancedFlowProtocol {

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
                let component = try await applePayComponent(from: paymentMethods)
                self.adyenComponent = component
                hideLoading()
                present(component: component)
            } catch {
                hideLoading()
                handleError(error)
            }
        }
    }

    private func applePayComponent(from paymentMethods: PaymentMethods) async throws -> CheckoutPaymentComponent {
        let configuration = try CheckoutConfiguration(
            environment: ConfigurationConstants.componentsEnvironment,
            amount: ConfigurationConstants.current.amount,
            clientKey: ConfigurationConstants.clientKey,
            analyticsConfiguration: .init(
                isEnabled: ConfigurationConstants.current.analyticsSettings.isEnabled
            )
        ) {
            try ConfigurationConstants.current
                .applePayConfiguration(using: .demoWithShippingFields)
                .onAuthorize { payment in
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
                .onSelectShippingContact { contact, summaryItems in
                    var items = summaryItems
                    if let last = items.last {
                        items = items.dropLast()
                        let cityLabel = contact.postalAddress?.city ?? "Somewhere"
                        items.append(.init(
                            label: "Shipping \(cityLabel)",
                            amount: NSDecimalNumber(value: 5.0)
                        ))
                        items.append(.init(label: last.label, amount: NSDecimalNumber(value: last.amount.floatValue + 5.0)))
                    }
                    return PKPaymentRequestShippingContactUpdate(paymentSummaryItems: items)
                }
                .onSelectShippingMethod { shippingMethod, summaryItems in
                    var items = summaryItems
                    if let last = items.last {
                        items = items.dropLast()
                        items.append(shippingMethod)
                        items.append(.init(
                            label: last.label,
                            amount: NSDecimalNumber(value: last.amount.floatValue + shippingMethod.amount.floatValue)
                        ))
                    }
                    return PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: items)
                }
                .onChangeCouponCode { _, summaryItems in
                    var items = summaryItems
                    if let last = items.last {
                        items = items.dropLast()
                        // make sure your backend's amount and apple pay sheet amount are the same
                        items.append(.init(label: "Coupon", amount: NSDecimalNumber(value: -5.0)))
                        items.append(.init(label: last.label, amount: NSDecimalNumber(value: last.amount.floatValue - 5.0)))
                    }
                    return PKPaymentRequestCouponCodeUpdate(paymentSummaryItems: items)
                }
                .onSelectPaymentMethod { paymentMethod, summaryItems in
                    // Example: Add a processing fee based on card type
                    var items = summaryItems
                    if let last = items.last {
                        items = items.dropLast()
                        let cardType = paymentMethod.displayName ?? "Card"
                        items.append(.init(
                            label: "Processing Fee (\(cardType))",
                            amount: NSDecimalNumber(value: 1.0)
                        ))
                        items.append(.init(label: last.label, amount: NSDecimalNumber(value: last.amount.floatValue + 1.0)))
                    }
                    return PKPaymentRequestPaymentMethodUpdate(paymentSummaryItems: items)
                }
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

        return try checkout.createPaymentComponent(for: .applePay)
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

extension ApplePayComponentAdvancedFlowExample: PresentationDelegate {

    func present(component: any PresentableComponent) {
        presenter?.present(viewController: component.viewController, completion: nil)
    }
}
