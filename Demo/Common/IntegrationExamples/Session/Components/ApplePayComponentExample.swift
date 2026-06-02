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

    private var checkout: SessionCheckout?
    private var adyenComponent: CheckoutPaymentComponent?
    private var latestApplePayAmount = ConfigurationConstants.current.amount

    internal lazy var apiClient = ApiClientHelper.generateApiClient()
    private lazy var asyncApiClient = ApiClientHelper.generateAsyncApiClient()

    /// comes from demo app protocol, unused on new structure
    internal var context: AdyenContext?

    internal init() {}

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
                }.onShippingContactChange { contact, summaryItems in
                    let cityLabel = contact.postalAddress?.city ?? "Somewhere"
                    let items = self.updatedSummaryItems(
                        from: summaryItems,
                        appendedItems: [
                            .init(
                                label: "Shipping \(cityLabel)",
                                amount: NSDecimalNumber(value: 5.0)
                            )
                        ],
                        totalAmountDelta: 5.0
                    )
                    self.updateLatestApplePayAmount(using: items)
                    return PKPaymentRequestShippingContactUpdate(paymentSummaryItems: items)
                }
                .onShippingMethodChange { shippingMethod, summaryItems in
                    let items = self.updatedSummaryItems(
                        from: summaryItems,
                        appendedItems: [shippingMethod],
                        totalAmountDelta: shippingMethod.amount.doubleValue
                    )
                    self.updateLatestApplePayAmount(using: items)
                    return PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: items)
                }
                .onCouponCodeChange { _, summaryItems in
                    // make sure your backend's amount and apple pay sheet amount are the same
                    let items = self.updatedSummaryItems(
                        from: summaryItems,
                        appendedItems: [.init(label: "Coupon", amount: NSDecimalNumber(value: -5.0))],
                        totalAmountDelta: -5.0
                    )
                    self.updateLatestApplePayAmount(using: items)
                    return PKPaymentRequestCouponCodeUpdate(paymentSummaryItems: items)
                }
                .onPaymentMethodChange { paymentMethod, summaryItems in
                    // Example: Add a processing fee based on card type
                    let cardType = paymentMethod.displayName ?? "Card"
                    let items = self.updatedSummaryItems(
                        from: summaryItems,
                        appendedItems: [
                            .init(
                                label: "Processing Fee (\(cardType))",
                                amount: NSDecimalNumber(value: 1.0)
                            )
                        ],
                        totalAmountDelta: 1.0
                    )
                    self.updateLatestApplePayAmount(using: items)
                    return PKPaymentRequestPaymentMethodUpdate(paymentSummaryItems: items)
                }
        }

        let checkout = try await Checkout.setup(
            with: sessionResponse,
            configuration: configuration,
            presentationDelegate: self
        )
        .onBeforeSubmit { data in
            print("onBeforeSubmit: shopperName: \(String(describing: data.shopperName))")
            print("onBeforeSubmit: shopperEmail: \(String(describing: data.shopperEmail))")
            print("onBeforeSubmit: billingAddress: \(String(describing: data.billingAddress))")
            print("onBeforeSubmit: deliveryAddress: \(String(describing: data.deliveryAddress))")

            switch ConfigurationConstants.current.applePaySettings.onBeforeSubmitMode {
            case .updateData:
                let updatedData = data
                    .replacing(shopperName: ShopperName(firstName: "Demo", lastName: "Shopper"))
                    .replacing(shopperEmail: "updatedForDemo-\(ConfigurationConstants.shopperEmail)")
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
        .onComplete { [weak self] result in
            self?.dismissAndShowAlert(
                result.resultCode.isSuccess,
                result.resultCode.rawValue
            )
        }
        .onError { [weak self] error in
            self?.dismissAndShowAlert(false, error.localizedDescription)
        }

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

    private func updatedSummaryItems(
        from summaryItems: [PKPaymentSummaryItem],
        appendedItems: [PKPaymentSummaryItem],
        totalAmountDelta: Double
    ) -> [PKPaymentSummaryItem] {
        guard let total = summaryItems.last else {
            return summaryItems
        }

        var updatedItems = Array(summaryItems.dropLast())
        updatedItems.append(contentsOf: appendedItems)
        updatedItems.append(
            .init(
                label: total.label,
                amount: NSDecimalNumber(value: total.amount.doubleValue + totalAmountDelta)
            )
        )
        return updatedItems
    }

    private func updateLatestApplePayAmount(using summaryItems: [PKPaymentSummaryItem]) {
        guard let total = summaryItems.last else {
            return
        }

        let currentAmount = ConfigurationConstants.current.amount
        let updatedValue = AmountFormatter.minorUnitAmount(
            from: total.amount.decimalValue,
            currencyCode: currentAmount.currencyCode,
            localeIdentifier: currentAmount.localeIdentifier
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

extension ApplePayComponentExample: PresentationDelegate {

    func present(component: any PresentableComponent) {
        presenter?.present(viewController: component.viewController, completion: nil)
    }
}
