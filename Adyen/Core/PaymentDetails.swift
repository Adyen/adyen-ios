//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// An object that holds the list of `InputDetail` items required for to process a transaction.
public class PaymentDetails {
    
    // MARK: - Initializing
    
    init(details: [InputDetail]) {
        list = details
    }
    
    // MARK: - Accessing Details List
    
    /// List of `InputDetail`.
    public var list: [InputDetail] = []
    
    // MARK: - Updating Input Details
    
    /// Update the detail defined by a given `key` with the string `value` provided.
    public func setDetail(value: String, forKey key: String) {
        list[key]?.stringValue = value
    }
    
    /// Update the detail defined by a given `key` with the bool `value` provided.
    public func setDetail(value: Bool?, forKey key: String) {
        list[key]?.boolValue = value
    }
    
    // MARK: - Internal
    
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
    
    // MARK: - Updating Apple Pay Details
    
    /// Fills details for the Apple Pay transaction.
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
    
    // MARK: - Updating Card Details
    
    /// Fills details for the card transaction with a token.
    public func fillCard(token: String, storeDetails: Bool? = nil) {
        setDetail(value: token, forKey: PaymentDetails.cardTokenKey)
        setDetail(value: storeDetails, forKey: PaymentDetails.cardStoreDetailsKey)
    }
    
    /// Fills details for the card transaction with CVC.
    public func fillCard(cvc: String) {
        setDetail(value: cvc, forKey: PaymentDetails.cardCvcKey)
    }
    
    /// Fills installments selection for the card transaction.
    public func fillCard(installmentPlanIdentifier: String) {
        setDetail(value: installmentPlanIdentifier, forKey: PaymentDetails.cardInstallmentsKey)
    }
}

// MARK: iDEAL

public extension PaymentDetails {
    private static let issuerKey = "idealIssuer"
    
    // MARK: - Updating iDEAL Details
    
    /// Fills details for the iDEAL transaction.
    public func fillIdeal(issuerIdentifier: String) {
        setDetail(value: issuerIdentifier, forKey: PaymentDetails.issuerKey)
    }
}

// MARK: SEPA Direct Debit

public extension PaymentDetails {
    private static let nameKey = "sepa.ownerName"
    private static let ibanKey = "sepa.ibanNumber"
    
    // MARK: - Updating SEPA Direct Debit Details
    
    /// Fill details for the SEPA transaction.
    public func fillSepa(name: String, iban: String) {
        setDetail(value: name, forKey: PaymentDetails.nameKey)
        setDetail(value: iban, forKey: PaymentDetails.ibanKey)
    }
}

// MARK: Address

public extension PaymentDetails {
    
    // MARK: - Updating Address Details
    
    /// An object that represents an address requested in PaymentDetails.
    public struct Address {
        
        // MARK: - Accessing Address Fields
        
        /// The street name.
        public var street: String
        
        /// The house number or name.
        public var houseNumberOrName: String
        
        /// The postal code.
        public var postalCode: String
        
        /// The city name.
        public var city: String
        
        /// An optional state or province name.
        public var stateOrProvince: String?
        
        /// The ISO country code.
        public var countryCode: String
        
    }
    
    /// Fills the billing address for a transaction that requires AVS.
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
