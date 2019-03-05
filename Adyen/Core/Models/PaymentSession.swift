//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation

/// A structure representing the current payment session.
public struct PaymentSession {
    
    // MARK: - Accessing Payment Information
    
    /// Information of the payment in the current session.
    public let payment: Payment
    
    /// Additional company information.
    public let company: Company?
    
    /// Line items describing the current payment.
    public let lineItems: [LineItem]?
    
    internal var paymentMethods: SectionedPaymentMethods
    internal let paymentData: String
    
    // MARK: - Environment
    
    internal let initiationURL: URL
    internal let deleteStoredPaymentMethodURL: URL
    internal let checkoutShopperBaseURL: URL
    
    // MARK: - Working with Card Encryption
    
    /// The public key to use for encrypting card data.
    public let publicKey: String?
    
    /// The generation date to use for encrypting card data.
    public let generationDate: Date?
    
}

// MARK: - PaymentSession.Payment

public extension PaymentSession {
    /// Information related to the payment in a payment session.
    struct Payment: Decodable {
        /// Describes the amount of a payment.
        public struct Amount: Decodable {
            
            /// Initializes an Amount.
            ///
            /// - Parameters:
            ///   - value: The value in minor units.
            ///   - currencyCode: The code of the currency.
            init(value: Int, currencyCode: String) {
                self.value = value
                self.currencyCode = currencyCode
            }
            
            /// The value of the amount in minor units.
            public var value: Int
            
            /// The code of the currency in which the amount's value is specified.
            public var currencyCode: String
            
            /// A formatted representation of the amount.
            public var formatted: String {
                return AmountFormatter.formatted(amount: value, currencyCode: currencyCode) ?? String(value) + " " + currencyCode
            }
            
            private enum CodingKeys: String, CodingKey {
                case value
                case currencyCode = "currency"
            }
        }
        
        /// The payment amount.
        @available(*, deprecated, renamed: "amount(for:)")
        public var amount: Amount {
            return originalAmount
        }
        
        /// The code of the country in which the payment is made.
        public let countryCode: String?
        
        /// A merchant specified reference relating to the payment.
        public let merchantReference: String
        
        /// Returns the amount taking in consideration the selected payment method surcharges,
        /// or the original amount if no payment method is provided.
        ///
        /// - Parameters:
        ///   - paymentMethod: The selected payment method or empty for original amount.
        /// - Returns: The amount.
        public func amount(for paymentMethod: PaymentMethod? = nil) -> Amount {
            guard let surcharge = paymentMethod?.surcharge else {
                return originalAmount
            }
            
            return Amount(value: surcharge.finalAmount, currencyCode: originalAmount.currencyCode)
        }
        
        internal let shopperReference: String?
        internal let shopperLocaleIdentifier: String?
        internal let expirationDate: Date
        
        private let originalAmount: Amount
        
        private enum CodingKeys: String, CodingKey {
            case originalAmount = "amount"
            case countryCode
            case merchantReference = "reference"
            case expirationDate = "sessionValidity"
            case shopperReference
            case shopperLocaleIdentifier = "shopperLocale"
        }
        
    }
}

// MARK: - PaymentSession.Company

public extension PaymentSession {
    /// A structure containing information of the company requesting the payment.
    struct Company: Decodable {
        /// The name of the company.
        public let name: String?
        
        internal let registrationNumber: String?
        internal let taxId: String?
        internal let registryLocation: String?
        internal let type: String?
        internal let homepage: String?
    }
}

// MARK: - PaymentSession.LineItem

public extension PaymentSession {
    /// A line item describing the payment.
    struct LineItem: Decodable {
        /// A unique identifier of the line item.
        public let identifier: String?
        
        /// A description of the line item.
        public let description: String?
        
        /// The number of items in this line item.
        public let numberOfItems: Int?
        
        /// The amount in minor units, excluding tax.
        public let amountExcludingTax: Int?
        
        /// The tax amount in minor units.
        public let taxAmount: Int?
        
        /// The amount in minor units, including tax.
        public let amountIncludingTax: Int?
        
        /// The percentage of tax applied.
        public let taxPercentage: Int?
        
        /// The tax category.
        public let taxCategory: String?
        
        // MARK: - Coding Keys
        
        private enum CodingKeys: String, CodingKey {
            case identifier = "id"
            case description
            case numberOfItems = "quantity"
            case amountExcludingTax
            case taxAmount
            case amountIncludingTax
            case taxPercentage
            case taxCategory
        }
        
    }
}
