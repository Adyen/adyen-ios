//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// Holds the list of `InputDetail` items required for a transaction.
public class PaymentDetails {
    
    /// List of `InputDetail`.
    public var list: [InputDetail] = []
    
    init(details: [InputDetail]) {
        list = details
    }
    
    /// Update the detail defined by a given `key` with the string `value` provided.
    public func setDetail(value: String, forKey key: String) {
        list[key]?.stringValue = value
    }
    
    /// Update the detail defined by a given `key` with the bool `value` provided.
    public func setDetail(value: Bool?, forKey key: String) {
        list[key]?.boolValue = value
    }
    
    /// A dictionary representation of the input details and their current values.
    internal var serialized: [String: Any] {
        func serialize(_ inputDetails: [InputDetail]) -> [String: Any] {
            var dictionary = [String: Any]()
            
            inputDetails.forEach { inputDetail in
                if let value = inputDetail.value {
                    dictionary[inputDetail.key] = value
                } else if let nestedInputDetails = inputDetail.inputDetails {
                    dictionary[inputDetail.key] = serialize(nestedInputDetails)
                }
            }
            
            return dictionary
        }
        
        return serialize(list)
    }
    
}

// MARK: Apple Pay

public extension PaymentDetails {
    private static let appleTokenKey = "additionalData.applepay.token"
    
    /// Fill details for the Apple Pay transaction.
    public func fillApplePay(token: String) {
        setDetail(value: token, forKey: PaymentDetails.appleTokenKey)
    }
}

// MARK: Card

public extension PaymentDetails {
    private static let cardTokenKey = "additionalData.card.encrypted.json"
    private static let cardStoreDetailsKey = "storeDetails"
    private static let cardInstallmentsKey = "installments"
    private static let cardCvcKey = "cardDetails.cvc"
    
    /// Fill details for the card transaction with a token.
    public func fillCard(token: String, storeDetails: Bool? = nil) {
        setDetail(value: token, forKey: PaymentDetails.cardTokenKey)
        setDetail(value: storeDetails, forKey: PaymentDetails.cardStoreDetailsKey)
    }
    
    /// Fill details for the card transaction with CVC.
    public func fillCard(cvc: String) {
        setDetail(value: cvc, forKey: PaymentDetails.cardCvcKey)
    }
    
    /// Fill installments selection for the card transaction.
    public func fillCard(installmentPlanIdentifier: String) {
        setDetail(value: installmentPlanIdentifier, forKey: PaymentDetails.cardInstallmentsKey)
    }
}

// MARK: iDEAL

public extension PaymentDetails {
    private static let issuerKey = "idealIssuer"
    
    /// Fill details for the iDEAL transaction.
    public func fillIdeal(issuerIdentifier: String) {
        setDetail(value: issuerIdentifier, forKey: PaymentDetails.issuerKey)
    }
}

// MARK: SEPA Direct Debit

public extension PaymentDetails {
    private static let nameKey = "sepa.ownerName"
    private static let ibanKey = "sepa.ibanNumber"
    
    /// Fill details for the SEPA transaction.
    public func fillSepa(name: String, iban: String) {
        setDetail(value: name, forKey: PaymentDetails.nameKey)
        setDetail(value: iban, forKey: PaymentDetails.ibanKey)
    }
}

// MARK: Address

public extension PaymentDetails {
    
    /// Represents an address requested in PaymentDetails.
    public struct Address {
        
        /// The street name in an address.
        public var street: String
        
        /// The house number or name in an address.
        public var houseNumberOrName: String
        
        /// The postal code in an address.
        public var postalCode: String
        
        /// The city name in an address.
        public var city: String
        
        /// The state or province name in an address.
        public var stateOrProvince: String?
        
        /// The ISO country code for the country in an address.
        public var countryCode: String
        
    }
    
    /// Fills the billing address for a transaction that requires AVS.
    ///
    /// - Parameter address: The address to fill.
    public func fillBillingAddress(_ address: Address) {
        guard let detail = list["billingAddress"] else {
            return
        }
        
        detail.inputDetails?["street"]?.stringValue = address.street
        detail.inputDetails?["houseNumberOrName"]?.stringValue = address.houseNumberOrName
        detail.inputDetails?["postalCode"]?.stringValue = address.postalCode
        detail.inputDetails?["city"]?.stringValue = address.city
        detail.inputDetails?["stateOrProvince"]?.stringValue = address.stateOrProvince
        detail.inputDetails?["country"]?.stringValue = address.countryCode
    }
    
}
