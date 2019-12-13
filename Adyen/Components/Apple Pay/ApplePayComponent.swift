//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import PassKit

/// A component that handles Apple Pay payments.
public class ApplePayComponent: NSObject, PaymentComponent, PresentableComponent, Localizable {
    
    /// Describes the error that can occur during Apple Pay payment.
    public enum Error: Swift.Error, LocalizedError {
        /// Indicates that the user can't make payments on any of the payment request’s supported networks.
        case userCannotMakePayment
        
        /// Indicates that the current device's hardware doesn't support ApplePay.
        case deviceDoesNotSupportApplyPay
        
        /// Indicates that the summaryItems array is empty.
        case emptySummaryItems
        
        /// Indicates that the grand total summary item is a negative value.
        case negativeGrandTotal
        
        /// Indicates that at least one of the summary items has an invalid amount.
        case invalidSummaryItem
        
        /// Indicates that the country code is invalid.
        case invalidCountryCode
        
        /// Indicates that the currency code is invalid.
        case invalidCurrencyCode
        
        /// :nodoc:
        public var errorDescription: String? {
            switch self {
            case .userCannotMakePayment:
                return "The user can’t make payments on any of the payment request’s supported networks."
            case .deviceDoesNotSupportApplyPay:
                return "The current device's hardware doesn't support ApplePay."
            case .emptySummaryItems:
                return "The summaryItems array is empty."
            case .negativeGrandTotal:
                return "The grand total summary item should be greater than or equal to zero."
            case .invalidSummaryItem:
                return "At least one of the summary items has an invalid amount."
            case .invalidCountryCode:
                return "The country code is invalid."
            case .invalidCurrencyCode:
                return "The currency code is invalid."
            }
        }
    }
    
    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?
    
    /// The Apple Pay payment method.
    public let paymentMethod: PaymentMethod
    
    /// The line items for this payment.
    public let summaryItems: [PKPaymentSummaryItem]
    
    /// Initializes the component.
    ///
    /// - Warning: `stopLoading()` must be called before dismissing this component.
    ///
    /// - Parameter paymentMethod: The Apple Pay payment method.
    /// - Parameter payment: A description of the payment. Must include an amount and country code.
    /// - Parameter merchantIdentifier: The merchant identifier..
    /// - Parameter summaryItems: The line items for this payment.
    /// - Throws: `ApplePayComponent.Error.userCannotMakePayment`
    /// if user can't make payments on any of the payment request’s supported networks.
    /// - Throws: `ApplePayComponent.Error.deviceDoesNotSupportApplyPay` if the current device's hardware doesn't support ApplePay.
    /// - Throws: `ApplePayComponent.Error.emptySummaryItems` if the summaryItems array is empty.
    /// - Throws: `ApplePayComponent.Error.negativeGrandTotal` if the grand total is negative.
    /// - Throws: `ApplePayComponent.Error.invalidSummaryItem` if at least one of the summary items has an invalid amount.
    /// - Throws: `ApplePayComponent.Error.invalidCountryCode` if the `payment.countryCode` is not a valid ISO country code.
    /// - Throws: `ApplePayComponent.Error.invalidCurrencyCode` if the `payment.amount.currencyCode` is not a valid ISO currency code.
    public init(paymentMethod: ApplePayPaymentMethod, payment: Payment, merchantIdentifier: String, summaryItems: [PKPaymentSummaryItem]) throws {
        guard PKPaymentAuthorizationViewController.canMakePayments() else {
            throw Error.deviceDoesNotSupportApplyPay
        }
        guard PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: ApplePayComponent.supportedNetworks) else {
            throw Error.userCannotMakePayment
        }
        guard let countryCode = payment.countryCode, CountryCodeValidator().isValid(countryCode) else {
            throw Error.invalidCountryCode
        }
        guard CurrencyCodeValidator().isValid(payment.amount.currencyCode) else {
            throw Error.invalidCurrencyCode
        }
        guard summaryItems.count > 0 else {
            throw Error.emptySummaryItems
        }
        guard let lastItem = summaryItems.last, lastItem.amount.doubleValue >= 0 else {
            throw Error.negativeGrandTotal
        }
        guard summaryItems.filter({ $0.amount.isEqual(to: NSDecimalNumber.notANumber) }).count == 0 else {
            throw Error.invalidSummaryItem
        }
        
        self.paymentMethod = paymentMethod
        self.applePayPaymentMethod = paymentMethod
        self.merchantIdentifier = merchantIdentifier
        self.summaryItems = summaryItems
        
        super.init()
        
        self.payment = payment
    }
    
    /// Initializes the component.
    ///
    /// - Parameter paymentMethod: The Apple Pay payment method.
    /// - Parameter merchantIdentifier: The merchant identifier.
    /// - Parameter summaryItems: The line items for this payment.
    @available(*, deprecated, message: "Use init(paymentMethod:payment:merchantIdentifier:summaryItems:) instead.")
    public init?(paymentMethod: ApplePayPaymentMethod, merchantIdentifier: String, summaryItems: [PKPaymentSummaryItem]) {
        guard PKPaymentAuthorizationViewController.canMakePayments() else {
            print("Failed to instantiate ApplePayComponent. PKPaymentAuthorizationViewController.canMakePayments returned false.")
            return nil
        }
        guard PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: ApplePayComponent.supportedNetworks) else {
            // swiftlint:disable:next line_length
            print("Failed to instantiate ApplePayComponent. PKPaymentAuthorizationViewController.canMakePayments(usingNetworks:) returned false.")
            return nil
        }
        
        self.paymentMethod = paymentMethod
        self.applePayPaymentMethod = paymentMethod
        self.merchantIdentifier = merchantIdentifier
        self.summaryItems = summaryItems
    }
    
    private let applePayPaymentMethod: ApplePayPaymentMethod
    
    // MARK: - Presentable Component Protocol
    
    /// :nodoc:
    public var viewController: UIViewController {
        return paymentAuthorizationViewController ?? errorAlertController
    }
    
    /// :nodoc:
    public var preferredPresentationMode: PresentableComponentPresentationMode {
        return .present
    }
    
    /// :nodoc:
    public var localizationTable: String?
    
    /// :nodoc:
    public func stopLoading(withSuccess success: Bool, completion: (() -> Void)?) {
        paymentAuthorizationCompletion?(success ? .success : .failure)
        dismissCompletion = completion
    }
    
    // MARK: - Private
    
    private var paymentAuthorizationCompletion: ((PKPaymentAuthorizationStatus) -> Void)?
    
    private var dismissCompletion: (() -> Void)?
    
    private let merchantIdentifier: String
    
    private lazy var errorAlertController: UIAlertController = {
        let alertController = UIAlertController(title: ADYLocalizedString("adyen.error.title", localizationTable),
                                                message: ADYLocalizedString("adyen.error.unknown", localizationTable),
                                                preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: ADYLocalizedString("adyen.dismissButton", localizationTable),
                                          style: .default) { [weak self] _ in
            self?.handle(
                UnknownError(
                    errorDescription: "Failed to instantiate PKPaymentAuthorizationViewController because of unknown error"
                )
            )
        }
        alertController.addAction(dismissAction)
        return alertController
    }()
    
    private lazy var paymentAuthorizationViewController: PKPaymentAuthorizationViewController? = {
        guard let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) else {
            print("Failed to instantiate PKPaymentAuthorizationViewController.")
            return nil
        }
        paymentAuthorizationViewController.delegate = self
        
        return paymentAuthorizationViewController
    }()
    
    internal lazy var paymentRequest: PKPaymentRequest = {
        let paymentRequest = PKPaymentRequest()
        
        paymentRequest.countryCode = payment?.countryCode ?? ""
        paymentRequest.merchantIdentifier = merchantIdentifier
        paymentRequest.currencyCode = payment?.amount.currencyCode ?? ""
        paymentRequest.supportedNetworks = ApplePayComponent.supportedNetworks
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.paymentSummaryItems = summaryItems
        
        return paymentRequest
    }()
    
    private static var supportedNetworks: [PKPaymentNetwork] {
        var networks: [PKPaymentNetwork] = [.visa, .masterCard, .amex, .discover, .interac]
        
        if #available(iOS 12.0, *) {
            networks.append(.maestro)
        }
        
        return networks
    }
    
    private func handle(_ error: Swift.Error) {
        delegate?.didFail(with: error, from: self)
    }
}

// MARK: - PKPaymentAuthorizationViewControllerDelegate

extension ApplePayComponent: PKPaymentAuthorizationViewControllerDelegate {
    
    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: dismissCompletion)
    }
    
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                                   didAuthorizePayment payment: PKPayment,
                                                   completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        paymentAuthorizationCompletion = completion
        
        let token = String(data: payment.token.paymentData, encoding: .utf8) ?? ""
        let network = payment.token.paymentMethod.network?.rawValue ?? ""
        let details = ApplePayDetails(paymentMethod: applePayPaymentMethod, token: token, network: network)
        
        self.delegate?.didSubmit(PaymentComponentData(paymentMethodDetails: details), from: self)
    }
}
