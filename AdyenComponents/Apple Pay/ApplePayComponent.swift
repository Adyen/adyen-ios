//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import PassKit

/// A component that handles Apple Pay payments.
public class ApplePayComponent: NSObject, PresentableComponent, PaymentComponent, FinalizableComponent {

    internal var resultConfirmed: Bool = false
    internal var viewControllerDidFinish: Bool = false
    internal let applePayPaymentMethod: ApplePayPaymentMethod

    /// :nodoc:
    public let apiContext: APIContext

    /// The Apple Pay payment method.
    public var paymentMethod: PaymentMethod { applePayPaymentMethod }

    /// Apple Pay component configuration.
    internal let configuration: Configuration

    internal var paymentAuthorizationViewController: PKPaymentAuthorizationViewController?

    internal var paymentAuthorizationCompletion: ((PKPaymentAuthorizationStatus) -> Void)?

    internal var finalizeCompletion: (() -> Void)?
    
    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?
    
    /// Initializes the component.
    /// - Warning: didFinalize() must be called before dismissing this component.
    ///
    /// - Parameter paymentMethod: The Apple Pay payment method. Must include country code.
    /// - Parameter apiContext: The API environment and credentials.
    /// - Parameter payment: The describes the current payment.
    /// - Parameter configuration: Apple Pay component configuration
    /// - Throws: `ApplePayComponent.Error.userCannotMakePayment`.
    /// if user can't make payments on any of the payment request’s supported networks.
    /// - Throws: `ApplePayComponent.Error.deviceDoesNotSupportApplyPay` if the current device's hardware doesn't support ApplePay.
    /// - Throws: `ApplePayComponent.Error.emptySummaryItems` if the summaryItems array is empty.
    /// - Throws: `ApplePayComponent.Error.negativeGrandTotal` if the grand total is negative.
    /// - Throws: `ApplePayComponent.Error.invalidSummaryItem` if at least one of the summary items has an invalid amount.
    /// - Throws: `ApplePayComponent.Error.invalidCountryCode` if the `payment.countryCode` is not a valid ISO country code.
    /// - Throws: `ApplePayComponent.Error.invalidCurrencyCode` if the `Amount.currencyCode` is not a valid ISO currency code.
    public init(paymentMethod: ApplePayPaymentMethod,
                apiContext: APIContext,
                configuration: Configuration) throws {
        guard PKPaymentAuthorizationViewController.canMakePayments() else {
            throw Error.deviceDoesNotSupportApplyPay
        }
        let supportedNetworks = paymentMethod.supportedNetworks
        guard configuration.allowOnboarding || Self.canMakePaymentWith(supportedNetworks) else {
            throw Error.userCannotMakePayment
        }

        let request = configuration.createPaymentRequest(supportedNetworks: supportedNetworks)
        guard let viewController = ApplePayComponent.createPaymentAuthorizationViewController(from: request) else {
            throw UnknownError(
                errorDescription: "Failed to instantiate PKPaymentAuthorizationViewController because of unknown error"
            )
        }

        self.configuration = configuration
        self.apiContext = apiContext
        self.paymentAuthorizationViewController = viewController
        self.applePayPaymentMethod = paymentMethod
        super.init()

        viewController.delegate = self
    }
    
    // MARK: - Presentable Component Protocol
    
    /// :nodoc:
    public var viewController: UIViewController {
        createPaymentAuthorizationViewController()
    }

    /// Finalizes ApplePay payment after being processed by payment provider.
    /// - Parameter success: The status of the payment.
    public func didFinalize(with success: Bool, completion: (() -> Void)?) {
        self.resultConfirmed = true
        if paymentAuthorizationCompletion == nil {
            completion?()
        } else {
            finalizeCompletion = completion
            paymentAuthorizationCompletion?(success ? .success : .failure)
            paymentAuthorizationCompletion = nil
        }
    }

    // MARK: - Private

    private func createPaymentAuthorizationViewController() -> PKPaymentAuthorizationViewController {
        if paymentAuthorizationViewController == nil {
            let supportedNetworks = applePayPaymentMethod.supportedNetworks
            let request = configuration.createPaymentRequest(supportedNetworks: supportedNetworks)
            paymentAuthorizationViewController = Self.createPaymentAuthorizationViewController(from: request)
            paymentAuthorizationViewController?.delegate = self
            paymentAuthorizationCompletion = nil
            resultConfirmed = false
        }
        return paymentAuthorizationViewController!
    }
    
    private static func createPaymentAuthorizationViewController(from request: PKPaymentRequest) -> PKPaymentAuthorizationViewController? {
        guard let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: request) else {
            adyenPrint("Failed to instantiate PKPaymentAuthorizationViewController.")
            return nil
        }
        
        return paymentAuthorizationViewController
    }

    private static func canMakePaymentWith(_ networks: [PKPaymentNetwork]) -> Bool {
        PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: networks)
    }

}
