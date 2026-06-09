//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import PassKit

extension ApplePayComponent {

    // TODO: Make package and decide
    // how to connect with CheckoutError
    /// Describes the errors that can occur during Apple Pay payment.
    public enum Error: Swift.Error, LocalizedError {
        /// Indicates that the user can't make payments on any of the payment request’s supported networks.
        case userCannotMakePayment

        /// Indicates that the current device's hardware doesn't support ApplePay.
        case deviceDoesNotSupportApplePay

        /// Indicates that the summaryItems array is empty.
        case emptySummaryItems
        
        /// Indicates that the merchant identifier is missing.
        case emptyMerchantIdentifier

        /// Indicates that the grand total summary item is a negative value.
        case negativeGrandTotal

        /// Indicates that at least one of the summary items has an invalid amount.
        case invalidSummaryItem

        /// Indicates that the country code is invalid.
        case invalidCountryCode

        /// Indicates that the currency code is invalid.
        case invalidCurrencyCode

        /// Indicates that the token was generated incorrectly.
        case invalidToken

        /// Indicates that no Apple Pay configuration was provided.
        case missingConfiguration

        /// Indicates that the payment authorization view controller could not be created,
        /// typically because the payment request contains invalid or missing fields.
        case invalidPaymentRequest

        public var errorDescription: String? {
            switch self {
            case .userCannotMakePayment:
                return "The user can’t make payments on any of the payment request’s supported networks."
            case .deviceDoesNotSupportApplePay:
                return "The current device's hardware doesn't support ApplePay."
            case .emptySummaryItems:
                return "The summaryItems array is empty."
            case .emptyMerchantIdentifier:
                return "The merchant identifier is missing, provide a valid one."
            case .negativeGrandTotal:
                return "The grand total summary item should be greater than or equal to zero."
            case .invalidSummaryItem:
                return "At least one of the summary items has an invalid amount."
            case .invalidCountryCode:
                return "The country code is invalid."
            case .invalidCurrencyCode:
                return "The currency code is invalid."
            case .invalidToken:
                return "The Apple Pay token is invalid. Make sure you are using physical device, not a Simulator."
            case .missingConfiguration:
                return "No Apple Pay configuration was provided. Supply an ApplePayConfiguration via the CheckoutConfiguration DSL."
            case .invalidPaymentRequest:
                return "The payment request is invalid or could not be used to create a payment authorization view controller."
            }
        }
    }

}
