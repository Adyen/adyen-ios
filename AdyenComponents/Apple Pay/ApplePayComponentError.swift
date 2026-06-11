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

        /// Indicates that calling submit is not supported for Apple Pay.
        case submitNotSupported
        
        /// Indicates that no Apple Pay configuration was provided.
        case missingConfiguration

        /// Indicates that the payment authorization view controller could not be created,
        /// typically because the payment request contains invalid or missing fields.
        case invalidPaymentRequest

        public var errorDescription: String? {
            switch self {
            case .userCannotMakePayment:
                return String(localized: "The user can't make payments on any of the payment request's supported networks.")
            case .deviceDoesNotSupportApplePay:
                return String(localized: "The current device's hardware doesn't support Apple Pay.")
            case .emptySummaryItems:
                return String(localized: "The summaryItems array is empty.")
            case .emptyMerchantIdentifier:
                return String(localized: "The merchant identifier is missing, provide a valid one.")
            case .negativeGrandTotal:
                return String(localized: "The grand total summary item should be greater than or equal to zero.")
            case .invalidSummaryItem:
                return String(localized: "At least one of the summary items has an invalid amount.")
            case .invalidCountryCode:
                return String(localized: "The country code is invalid.")
            case .invalidCurrencyCode:
                return String(localized: "The currency code is invalid.")
            case .invalidToken:
                return String(localized: "The Apple Pay token is invalid. Make sure you are using a physical device, not a Simulator.")
            case .submitNotSupported:
                return String(localized: "Submit call is not supported.")
            case .missingConfiguration:
                return String(localized: "No Apple Pay configuration was provided. Supply an ApplePayConfiguration via the CheckoutConfiguration DSL.")
            case .invalidPaymentRequest:
                return String(localized: "The payment request is invalid or could not be used to create a payment authorization view controller.")
            }
        }
    }

}
