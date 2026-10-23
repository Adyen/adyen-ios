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
                let patchableSession = ConfigurationConstants.current.applePaySettings.onBeforeSubmitMode == .patchSession
                let sessionResponse = try await requestSessionInitialInfo(payable: !patchableSession)
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
        let plainPaymentSheet = ConfigurationConstants.current.applePaySettings.plainPaymentSheet
        let configuration = try CheckoutConfiguration(
            environment: ConfigurationConstants.componentsEnvironment,
            clientKey: ConfigurationConstants.clientKey,
            analyticsConfiguration: .init(
                isEnabled: ConfigurationConstants.current.analyticsSettings.isEnabled
            )
        ) {
            try ConfigurationConstants.current
                .applePayConfiguration(using: plainPaymentSheet ? .demo : .demoWithShippingFields)
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
                .applying(if: !plainPaymentSheet) {
                    $0.onSelectShippingContact { [weak self] contact, summaryItems in
                        guard let self else { return PKPaymentRequestShippingContactUpdate(paymentSummaryItems: summaryItems) }
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
                    .onSelectShippingMethod { [weak self] shippingMethod, summaryItems in
                        guard let self else { return PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: summaryItems) }
                        let items = self.updatedSummaryItems(
                            from: summaryItems,
                            appending: [shippingMethod]
                        )
                        self.updateLatestApplePayAmount(using: items)
                        return PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: items)
                    }
                    .onChangeCouponCode { [weak self] _, summaryItems in
                        guard let self else { return PKPaymentRequestCouponCodeUpdate(paymentSummaryItems: summaryItems) }
                        // make sure your backend's amount and apple pay sheet amount are the same
                        let items = self.updatedSummaryItems(
                            from: summaryItems,
                            appending: [.init(label: "Coupon", amount: NSDecimalNumber(value: -5.0))]
                        )
                        self.updateLatestApplePayAmount(using: items)
                        return PKPaymentRequestCouponCodeUpdate(paymentSummaryItems: items)
                    }
                    .onSelectPaymentMethod { [weak self] paymentMethod, summaryItems in
                        guard let self else { return PKPaymentRequestPaymentMethodUpdate(paymentSummaryItems: summaryItems) }
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
                .buttonAppearance(
                    .init(
                        buttonType: .donate,
                        buttonStyle: .whiteOutline,
                        cornerRadius: 6.0
                    )
                )
        }

        let callbacks = CheckoutCallbacks(
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
        .onBeforeSubmit { [weak self] data in
            guard let self else { return .abort }
            print("onBeforeSubmit: shopperName: \(String(describing: data.shopperName))")
            print("onBeforeSubmit: shopperEmail: \(String(describing: data.shopperEmail))")
            print("onBeforeSubmit: billingAddress: \(String(describing: data.billingAddress))")
            print("onBeforeSubmit: deliveryAddress: \(String(describing: data.deliveryAddress))")

            switch ConfigurationConstants.current.applePaySettings.onBeforeSubmitMode {
            case .updateData:
                var updatedData = data
                updatedData.shopperName = ShopperName(firstName: "Demo", lastName: "Shopper")
                updatedData.shopperEmail = "updatedForDemo-\(ConfigurationConstants.shopperEmail)"
                return .proceed(data: updatedData, sessionData: nil)
            case .abort:
                return .abort
            case .patchSession:
                do {
                    let patchedSession = try await self.patchSession(using: sessionResponse)
                    return .proceed(data: data, sessionData: patchedSession.sessionData)
                } catch {
                    return .abort
                }
            }
        }

        let checkout = try await Checkout.setup(
            with: sessionResponse,
            configuration: configuration,
            callbacks: callbacks
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

    private func dismissAndShowAlert(_ success: Bool, _ message: String) {
        presenter?.dismiss {
            // Payment is processed. Add your code here.
            let title = success ? "Success" : "Error"
            self.presenter?.presentAlert(withTitle: title, message: message)
        }
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
    
    // MARK: - Backend

    private func patchSession(using sessionResponse: SessionResponse) async throws -> SessionPatchResponse {
        let request = SessionPatchRequest(
            sessionId: sessionResponse.id,
            sessionData: sessionResponse.sessionData,
            amount: latestApplePayAmount
        )
        return try await asyncApiClient.performAsync(request)
    }
}

private extension ApplePayConfiguration {

    func applying(if condition: Bool, _ transform: (Self) -> Self) -> Self {
        condition ? transform(self) : self
    }
}
