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

    private var checkout: PaymentCheckout?
    private var adyenComponent: CheckoutPaymentComponent?
    private var latestApplePayAmount = ConfigurationConstants.current.amount

    internal lazy var apiClient = ApiClientHelper.generateApiClient()
    private lazy var asyncApiClient = ApiClientHelper.generateAsyncApiClient()

    /// comes from demo app protocol, unused on new structure
    internal var context: AdyenContext?

    /// Whether the app shows its own Apple Pay button instead of the component's button.
    private let usesOwnApplePayButton: Bool

    internal init(usesOwnApplePayButton: Bool = false) {
        self.usesOwnApplePayButton = usesOwnApplePayButton
    }

    internal func start() {
        startLoading()
        latestApplePayAmount = ConfigurationConstants.current.amount

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
                    let cityLabel = contact.postalAddress?.city ?? "Somewhere"
                    let items = self.updatedSummaryItems(
                        from: summaryItems,
                        appending: [
                            .init(
                                label: "Shipping \(cityLabel)",
                                amount: NSDecimalNumber(value: 5.0)
                            )
                        ]
                    )
                    self.updateLatestApplePayAmount(using: items)
                    return PKPaymentRequestShippingContactUpdate(paymentSummaryItems: items)
                }
                .onSelectShippingMethod { shippingMethod, summaryItems in
                    let items = self.updatedSummaryItems(
                        from: summaryItems,
                        appending: [shippingMethod]
                    )
                    self.updateLatestApplePayAmount(using: items)
                    return PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: items)
                }
                .onChangeCouponCode { _, summaryItems in
                    // make sure your backend's amount and apple pay sheet amount are the same
                    let items = self.updatedSummaryItems(
                        from: summaryItems,
                        appending: [.init(label: "Coupon", amount: NSDecimalNumber(value: -5.0))]
                    )
                    self.updateLatestApplePayAmount(using: items)
                    return PKPaymentRequestCouponCodeUpdate(paymentSummaryItems: items)
                }
                .onSelectPaymentMethod { paymentMethod, summaryItems in
                    // Example: Add a processing fee based on card type
                    let cardType = paymentMethod.displayName ?? "Card"
                    let items = self.updatedSummaryItems(
                        from: summaryItems,
                        appending: [
                            .init(
                                label: "Processing Fee (\(cardType))",
                                amount: NSDecimalNumber(value: 1.0)
                            )
                        ]
                    )
                    self.updateLatestApplePayAmount(using: items)
                    return PKPaymentRequestPaymentMethodUpdate(paymentSummaryItems: items)
                }
        }

        let callbacks = AdvancedCheckoutCallbacks(
            onSubmit: { [weak self] data in
                guard let self else { return .completion(resultCode: "Error") }
                return await self.callPayments(with: data)
            },
            onAdditionalDetails: { [weak self] data in
                guard let self else { return .completion(resultCode: "Error") }
                return await self.callDetails(with: data)
            },
            onComplete: { [weak self] result in
                self?.dismissAndShowAlert(
                    result.resultCode.isSuccess,
                    result.resultCode.rawValue
                )
            },
            onFailure: { [weak self] error in
                self?.dismissAndShowAlert(false, error.localizedDescription)
            }
        )

        let checkout = try await Checkout.setup(
            with: paymentMethods,
            configuration: configuration,
            callbacks: callbacks
        )

        self.checkout = checkout

        return try checkout.createPaymentComponent(for: .applePay)
    }

    // MARK: - Backend calls

    private func callPayments(with data: PaymentComponentData) async -> SubmitResult {
        do {
            // Charge the total the shopper approved on the Apple Pay sheet.
            let request = PaymentsRequest(data: data, amount: latestApplePayAmount)
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
        guard !usesOwnApplePayButton else {
            // The shopper already tapped the app's own Apple Pay button, so open the sheet directly.
            component.submit()
            return
        }

        let componentViewController = component.viewController
        componentViewController.view.backgroundColor = .systemBackground
        componentViewController.navigationItem.leftBarButtonItem = .init(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelPressed)
        )
        let navigation = UINavigationController(rootViewController: componentViewController)
        presenter?.present(viewController: navigation, completion: nil)
    }

    @objc private func cancelPressed() {
        presenter?.dismiss(completion: nil)
    }

    private func updatedSummaryItems(
        from summaryItems: [PKPaymentSummaryItem],
        appending appendedItems: [PKPaymentSummaryItem]
    ) -> [PKPaymentSummaryItem] {
        guard let total = summaryItems.last else {
            return summaryItems
        }

        let updatedTotal = appendedItems.reduce(total.amount) { $0.adding($1.amount) }
        return Array(summaryItems.dropLast()) + appendedItems + [PKPaymentSummaryItem(label: total.label, amount: updatedTotal)]
    }

    private func updateLatestApplePayAmount(using summaryItems: [PKPaymentSummaryItem]) {
        guard let total = summaryItems.last else {
            return
        }

        let currentAmount = ConfigurationConstants.current.amount
        let updatedValue = AmountFormatter.minorUnitAmount(
            from: total.amount.decimalValue,
            currencyCode: currentAmount.currencyCode
        )
        latestApplePayAmount = Amount(
            value: updatedValue,
            currencyCode: currentAmount.currencyCode,
            localeIdentifier: currentAmount.localeIdentifier
        )
    }

    private func dismissAndShowAlert(_ success: Bool, _ message: String) {
        presenter?.dismiss {
            // Payment is processed. Add your code here.
            let title = success ? "Success" : "Error"
            self.presenter?.presentAlert(withTitle: title, message: message)
        }
    }
}
