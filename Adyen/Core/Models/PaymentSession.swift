//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation

/// A structure representing the current payment session.
public struct PaymentSession: Decodable {

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
    
    private let checkoutShopperBaseURL: URL
    
    // MARK: - Working with Card Encryption
    
    /// The public key to use for encrypting card data.
    public let publicKey: String?
    
    /// The generation date to use for encrypting card data.
    public let generationDate: Date?
    
    // MARK: - Decoding
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.payment = try container.decode(Payment.self, forKey: .payment)
        self.initiationURL = try container.decode(URL.self, forKey: .initiationURL)
        self.checkoutShopperBaseURL = try container.decode(URL.self, forKey: .checkoutShopperBaseURL)
        self.deleteStoredPaymentMethodURL = try container.decode(URL.self, forKey: .deleteStoredPaymentMethodURL)
        self.publicKey = try container.decodeIfPresent(String.self, forKey: .publicKey)
        self.generationDate = try container.decodeIfPresent(Date.self, forKey: .generationDate)
        self.paymentData = try container.decode(String.self, forKey: .paymentData)
        self.company = try container.decodeIfPresent(Company.self, forKey: .company)
        self.lineItems = try container.decodeIfPresent([LineItem].self, forKey: .lineItems)
        
        self.paymentMethods = try SectionedPaymentMethods(from: decoder)
        
        fillInLogoURLs()
    }
    
    private enum CodingKeys: String, CodingKey {
        case payment
        case paymentMethods
        case storedPaymentMethods = "oneClickPaymentMethods"
        case environment
        case initiationURL = "initiationUrl"
        case checkoutShopperBaseURL = "checkoutshopperBaseUrl"
        case deleteStoredPaymentMethodURL = "disableRecurringDetailUrl"
        case publicKey
        case generationDate = "generationtime"
        case paymentData
        case lineItems
        case company
    }
    
    // MARK: - Private
    
    private mutating func fillInLogoURLs() {
        paymentMethods.preferred = paymentMethodsWithLogoURLs(paymentMethods.preferred)
        paymentMethods.other = paymentMethodsWithLogoURLs(paymentMethods.other)
    }
    
    func paymentMethodsWithLogoURLs(_ paymentMethods: [PaymentMethod]) -> [PaymentMethod] {
        var mutatedPaymentMethods: [PaymentMethod] = []
        
        for var paymentMethod in paymentMethods {
            let logoURL = LogoURLProvider.logoURL(for: paymentMethod, baseURL: checkoutShopperBaseURL)
            paymentMethod.logoURL = logoURL
            
            if let issuerDetail = paymentMethod.details.issuer, case let .select(issuers) = issuerDetail.inputType {
                let issuersWithLogoURLs = issuers.map { issuer -> PaymentDetail.SelectItem in
                    var issuerWithLogoURL = issuer
                    issuerWithLogoURL.logoURL = LogoURLProvider.logoURL(for: paymentMethod, selectItem: issuer, baseURL: checkoutShopperBaseURL)
                    
                    return issuerWithLogoURL
                }
                
                paymentMethod.details.issuer?.inputType = .select(issuersWithLogoURLs)
            }
            
            paymentMethod.children = paymentMethodsWithLogoURLs(paymentMethod.children)
            mutatedPaymentMethods.append(paymentMethod)
        }
        
        return mutatedPaymentMethods
    }
    
}

// MARK: - PaymentSession.Payment

public extension PaymentSession {
    /// Information related to the payment in a payment session.
    public struct Payment: Decodable {
        /// Describes the amount of a payment.
        public struct Amount: Decodable {
            /// The value of the amount in minor units.
            public var value: Int
            
            /// The code of the currency in which the amount's value is specified.
            public var currencyCode: String
            
            private enum CodingKeys: String, CodingKey {
                case value
                case currencyCode = "currency"
            }
            
            /// A formatted representation of the amount.
            public var formatted: String {
                return AmountFormatter.formatted(amount: value, currencyCode: currencyCode) ?? String(value) + " " + currencyCode
            }
        }
        
        /// The payment amount.
        public let amount: Amount
        
        /// The code of the country in which the payment is made.
        public let countryCode: String?
        
        /// A merchant specified reference relating to the payment.
        public let merchantReference: String
        
        internal let shopperReference: String?
        internal let shopperLocaleIdentifier: String?
        internal let expirationDate: Date
        
        private enum CodingKeys: String, CodingKey {
            case amount
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
    public struct Company: Decodable {
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
    public struct LineItem: Decodable {
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
