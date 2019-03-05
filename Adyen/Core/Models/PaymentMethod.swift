//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation

/// A structure representing a payment method that can be used to complete a payment.
public struct PaymentMethod: Decodable {
    
    // MARK: - Accessing Payment Method Information
    
    /// A string identifying the type of payment method, such as `"card"`, `"ideal"`, `"applepay"`.
    public let type: String
    
    /// The name of the payment method.
    public let name: String
    
    /// A URL to the logo of the payment method.
    public internal(set) var logoURL: URL?
    
    /// A dictionary with arbitrary configuration values.
    public let configuration: [String: Any]?
    
    // MARK: - Handling Input Details
    
    /// The details that should be filled in order to initiate a payment with this method.
    public var details: [PaymentDetail]
    
    // MARK: - Accessing Previously Used Details
    
    /// The details that were previously used to complete a payment with this payment method. Only available for stored payment methods.
    public let storedDetails: StoredPaymentDetails?
    
    // MARK: - Handling Grouped Payment Methods
    
    /// A collection of payment methods that are part of this payment method.
    public internal(set) var children: [PaymentMethod]
    
    // MARK: - Internal
    
    /// The group in which the payment method is grouped.
    internal let group: Group?
    
    /// The payment method data.
    internal let paymentMethodData: String
    
    /// Initializes a parent payment method with an array of children.
    ///
    /// - Parameter children: The children to initialize the parent payment method with.
    internal init(children: [PaymentMethod]) {
        guard !children.isEmpty else {
            fatalError("Can't initialize a parent payment method with an empty array of chilren.")
        }
        
        guard let group = children.first?.group else {
            fatalError("Children must have a group.")
        }
        
        self.type = group.type
        self.name = group.name
        self.configuration = children[0].configuration
        self.details = children[0].details
        self.storedDetails = nil
        self.children = children
        self.group = nil
        self.paymentMethodData = group.paymentMethodData
    }
    
    // MARK: - Decoding
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.type = try container.decode(String.self, forKey: .type)
        self.name = try container.decode(String.self, forKey: .name)
        self.configuration = try container.decodeIfPresent([String: Any].self, forKey: .configuration)
        self.details = try container.decodeIfPresent([PaymentDetail].self, forKey: .details) ?? []
        self.storedDetails = try PaymentMethod.decodeStoredDetails(from: decoder)
        self.children = []
        self.group = try container.decodeIfPresent(Group.self, forKey: .group)
        self.paymentMethodData = try container.decode(String.self, forKey: .paymentMethodData)
    }
    
    private static func decodeStoredDetails(from decoder: Decoder) throws -> StoredPaymentDetails? {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard container.contains(.storedDetails) else {
            return nil
        }
        
        let nestedContainer = try container.nestedContainer(keyedBy: StoredDetailsCodingKeys.self, forKey: .storedDetails)
        if nestedContainer.contains(.card) {
            return try nestedContainer.decode(StoredCardPaymentDetails.self, forKey: .card)
        } else if nestedContainer.contains(.emailAddress) {
            let emailAddress = try nestedContainer.decode(String.self, forKey: .emailAddress)
            
            return StoredPayPalPaymentDetails(emailAddress: emailAddress)
        }
        
        return nil
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case configuration
        case details
        case storedDetails
        case group
        case paymentMethodData
    }
    
    private enum StoredDetailsCodingKeys: String, CodingKey {
        case card
        case emailAddress
    }
    
}

// MARK: - PaymentMethod.Surcharge

public extension PaymentMethod {
    
    /// A struct that holds the payment method surchage information
    struct Surcharge {
        
        /// Surcharge fixed cost in minor units.
        var fixedCost: Int?
        
        /// The code of the currency in which the fixed cost is specified.
        var currencyCode: String
        
        /// Variable cost percentage in minor units.
        var variableCost: Int?
        
        /// Final amount with surchage in minor units included on original request currency.
        var finalAmount: Int
        
        /// Surcharge total cost in minor units on original request currency.
        public var total: Int
        
        /// Formatted surcharge total cost.
        public var formatted: String {
            var formattedFixedCost = ""
            var formattedVariableCost = ""
            
            if let fixed = fixedCost, fixed != 0 {
                let formattedAmount = AmountFormatter.formatted(amount: fixed, currencyCode: currencyCode) ?? String(fixed) + " " + currencyCode
                formattedFixedCost = "+\(formattedAmount)"
            }
            
            if let variable = variableCost {
                formattedVariableCost = "+\(Double(variable) / 100)%"
            }
            
            let separator = formattedFixedCost.isEmpty || formattedVariableCost.isEmpty ? "" : ", "
            return formattedFixedCost + separator + formattedVariableCost
        }
    }
    
    /// The surcharge for the payment method if available, or nil if no surcharge is added.
    var surcharge: Surcharge? {
        guard let totalString = configuration?[PaymentMethod.totalKey] as? String, let total = Int(totalString),
            let finalAmountString = configuration?[PaymentMethod.finalAmountKey] as? String, let finalAmount = Int(finalAmountString),
            let currencyCode = configuration?[PaymentMethod.currencyCodeKey] as? String else {
            return nil
        }
        
        var variableCost: Int?
        var fixedCost: Int?
        
        if let variableCostString = configuration?[PaymentMethod.variableCostKey] as? String {
            variableCost = Int(variableCostString)
        }
        
        if let fixedCostString = configuration?[PaymentMethod.fixedCostKey] as? String {
            fixedCost = Int(fixedCostString)
        }
        
        return Surcharge(fixedCost: fixedCost, currencyCode: currencyCode, variableCost: variableCost, finalAmount: finalAmount, total: total)
    }
    
    // MARK: - Configuration Keys for Surcharge
    
    private static let variableCostKey = "surchargeVariableCost"
    private static let fixedCostKey = "surchargeFixedCost"
    private static let totalKey = "surchargeTotalCost"
    private static let currencyCodeKey = "surchargeCurrencyCode"
    private static let finalAmountKey = "surchargeFinalAmount"
}

// MARK: - PaymentMethod.Group

internal extension PaymentMethod {
    struct Group: Decodable {
        /// A string uniquely identifying the payment method group.
        let type: String
        
        /// The name of the payment method group.
        let name: String
        
        /// The payment method data.
        internal let paymentMethodData: String
    }
}

// MARK: - Hashable & Equatable

extension PaymentMethod: Hashable {
    /// :nodoc:
    public var hashValue: Int {
        return type.hashValue ^ name.hashValue ^ paymentMethodData.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(name)
        hasher.combine(paymentMethodData)
    }
    
    /// :nodoc:
    public static func == (lhs: PaymentMethod, rhs: PaymentMethod) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
}

// MARK: - Helpers

public extension PaymentMethod {
    /// The display name of the payment method, taking into account stored payment details.
    var displayName: String {
        guard let storedDetails = storedDetails else {
            return name
        }
        
        switch storedDetails {
        case let storedDetails as StoredCardPaymentDetails:
            return "••••\u{00a0}" + storedDetails.number
        case let storedDetails as StoredPayPalPaymentDetails:
            return storedDetails.emailAddress
        default:
            return name
        }
    }
    
    /// An accessible variant of the payment method's display name.
    var accessibilityLabel: String {
        guard let storedDetails = storedDetails else {
            return displayName
        }
        
        switch storedDetails {
        case let storedDetails as StoredCardPaymentDetails:
            return ADYLocalizedString("creditCard.stored.accessibilityLabel", name, storedDetails.number)
        case let storedDetails as StoredPayPalPaymentDetails:
            return "\(name) \(storedDetails.emailAddress)"
        default:
            return name
        }
    }
    
    /// Boolean value indicating whether the sole required input detail is an issuer selection.
    internal var requiresIssuerSelection: Bool {
        guard let detail = details.first, details.count == 1 else { return false }
        
        if case .select = detail.inputType {
            return true
        } else {
            return false
        }
    }
    
}

internal extension Collection where Element == PaymentMethod {
    /// Returns an array of payment methods grouped by each payment method's group (if present).
    var grouped: [PaymentMethod] {
        return grouped { paymentMethod in
            paymentMethod.group?.type
        }.compactMap { paymentMethods in
            guard paymentMethods.count != 1 else {
                return paymentMethods.first
            }
            
            return PaymentMethod(children: paymentMethods)
        }
    }
    
}
