//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenComponents
import PassKit

internal final class ApplePayComponentAdvancedFlowExample: InitialDataAdvancedFlowProtocol {

    // MARK: - Properties

    internal var paymentMethods: PaymentMethods?
    internal var applePayComponent: ApplePayComponent?
    internal weak var presenter: PresenterExampleProtocol?

    // MARK: - Initializers

    internal init() {}

    internal func start() {
        presenter?.showLoadingIndicator()
        requestPaymentMethods(order: nil) { [weak self] result in
            guard let self else { return }

            self.presenter?.hideLoadingIndicator()

            switch result {
            case let .success(paymentMethods):
                self.presentComponent(with: paymentMethods)

            case let .failure(error):
                self.presentAlert(with: error)
            }
        }
    }

    // MARK: Presentation

    internal func presentComponent(with paymentMethods: PaymentMethods) {
        do {
            let component = try applePayComponent(from: paymentMethods)
            let componentViewController = component.viewController
            presenter?.present(viewController: componentViewController, completion: nil)
            applePayComponent = component
        } catch {
            self.presentAlert(with: error)
        }
    }

    internal func applePayComponent(from paymentMethods: PaymentMethods?) throws -> ApplePayComponent {
        guard
            let paymentMethod = paymentMethods?.paymentMethod(ofType: ApplePayPaymentMethod.self)
        else { throw IntegrationError.paymentMethodNotAvailable(paymentMethod: ApplePayPaymentMethod.self)
        }
        let applePayPayment = try ApplePayPayment(payment: ConfigurationConstants.current.payment,
                                                  brand: ConfigurationConstants.appName)
        var config = ApplePayComponent.Configuration(payment: applePayPayment,
                                                     merchantIdentifier: ConfigurationConstants.current.applePayConfiguration.merchantIdentifier)
        config.allowOnboarding = ConfigurationConstants.current.applePayConfiguration.allowOnboarding
        config.supportsCouponCode = true
        config.shippingType = .delivery
        config.requiredShippingContactFields = [.postalAddress]
        config.requiredBillingContactFields = [.postalAddress]
        config.shippingMethods = ConfigurationConstants.shippingMethods

        let component = try ApplePayComponent(paymentMethod: paymentMethod,
                                              context: context,
                                              configuration: config)
        component.delegate = self
        component.applePayDelegate = self
        return component
    }

    // MARK: - Payment response handling

    private func paymentResponseHandler(result: Result<PaymentsResponse, Error>) {
        switch result {
        case let .success(response):
            finish(with: response)
        case let .failure(error):
            finish(with: error)
        }
    }

    internal func finish(with result: PaymentsResponse) {
        let success = result.resultCode == .authorised || result.resultCode == .received || result.resultCode == .pending
        let message = "\(result.resultCode.rawValue) \(result.amount?.formatted ?? "")"
        finalize(success, message)
    }

    internal func finish(with error: Error) {
        let message: String
        if let componentError = (error as? ComponentError), componentError == ComponentError.cancelled {
            message = "Cancelled"
        } else {
            message = error.localizedDescription
        }
        finalize(false, message)
    }

    private func finalize(_ success: Bool, _ message: String) {
        applePayComponent?.finalizeIfNeeded(with: success) { [weak self] in
            guard let self else { return }
            self.dismissAndShowAlert(success, message)
        }
    }

    internal func dismissAndShowAlert(_ success: Bool, _ message: String) {
        presenter?.dismiss {
            // Payment is processed. Add your code here.
            let title = success ? "Success" : "Error"
            self.presenter?.presentAlert(withTitle: title, message: message)
        }
    }

    private func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        presenter?.presentAlert(with: error, retryHandler: retryHandler)
    }

}

extension ApplePayComponentAdvancedFlowExample: PaymentComponentDelegate {

    internal func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        let request = PaymentsRequest(data: data)
        apiClient.perform(request) { [weak self] result in
            self?.paymentResponseHandler(result: result)
        }
    }

    internal func didFail(with error: Error, from component: PaymentComponent) {
        finish(with: error)
    }

}

extension ApplePayComponentAdvancedFlowExample: ApplePayComponentDelegate {

    func didUpdate(contact: PKContact,
                   for payment: ApplePayPayment,
                   completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void) {
        var items = payment.summaryItems
        if let last = items.last {
            items = items.dropLast()
            // Below hard coded values are for testing purpose. Please add your own string and amount if you want to use these.
            let cityLabel = contact.postalAddress?.city ?? "Somewhere"
            items.append(.init(label: "Shipping \(cityLabel)",
                               amount: NSDecimalNumber(value: 5.0)))
            items.append(.init(label: last.label, amount: NSDecimalNumber(value: last.amount.floatValue + 5.0)))
        }
        completion(.init(paymentSummaryItems: items))
    }

    func didUpdate(shippingMethod: PKShippingMethod,
                   for payment: ApplePayPayment,
                   completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
        var items = payment.summaryItems
        if let last = items.last {
            items = items.dropLast()
            items.append(shippingMethod)
            items.append(.init(label: last.label,
                               amount: NSDecimalNumber(value: last.amount.floatValue + shippingMethod.amount.floatValue)))
        }
        completion(.init(paymentSummaryItems: items))
    }

    @available(iOS 15.0, *)
    func didUpdate(couponCode: String,
                   for payment: ApplePayPayment,
                   completion: @escaping (PKPaymentRequestCouponCodeUpdate) -> Void) {
        var items = payment.summaryItems
        if let last = items.last {
            items = items.dropLast()
            // Below hard coded values are for testing purpose. Please add your own string and amount if you want to use these.
            items.append(.init(label: "Coupon", amount: NSDecimalNumber(value: -5.0)))
            items.append(.init(label: last.label, amount: NSDecimalNumber(value: last.amount.floatValue - 5.0)))
        }
        completion(.init(paymentSummaryItems: items))
    }

}
