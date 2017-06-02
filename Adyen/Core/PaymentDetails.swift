//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// Holds the list of `InputDetail` needed for the transaction.
public class PaymentDetails {
    
    /// List of `InputDetail`.
    public var list: [InputDetail] = []
    
    init(details: [InputDetail]) {
        list = details
    }
    
    /// Update the detail defined by a given `key` with the string `value` provided.
    public func setDetail(value: String, forKey key: String) {
        detailFor(key: key)?.stringValue = value
    }
    
    /// Update the detail defined by a given `key` with the bool `value` provided.
    public func setDetail(value: Bool?, forKey key: String) {
        detailFor(key: key)?.boolValue = value
    }
    
    private func detailFor(key: String) -> InputDetail? {
        return list.filter({ $0.key == key }).first
    }
}

public extension PaymentDetails {
    private static let appleTokenKey = "additionalData.applepay.token"
    
    /// Fill details for the Apple Pay transaction.
    public func fillApplePay(token: String) {
        setDetail(value: token, forKey: PaymentDetails.appleTokenKey)
    }
}

public extension PaymentDetails {
    private static let cardTokenKey = "additionalData.card.encrypted.json"
    private static let cardStoreDetailsKey = "storeDetails"
    private static let cardCvcKey = "cardDetails.cvc"
    
    /// Fill details for the Card transaction with a token.
    public func fillCard(token: String, storeDetails: Bool? = nil) {
        setDetail(value: token, forKey: PaymentDetails.cardTokenKey)
        setDetail(value: storeDetails, forKey: PaymentDetails.cardStoreDetailsKey)
    }
    
    /// Fill details for the Card transaction with CVC.
    public func fillCard(cvc: String) {
        setDetail(value: cvc, forKey: PaymentDetails.cardCvcKey)
    }
}

public extension PaymentDetails {
    private static let issuerKey = "idealIssuer"
    
    /// Fill details for the iDEAL transaction.
    public func fillIdeal(issuerIdentifier: String) {
        setDetail(value: issuerIdentifier, forKey: PaymentDetails.issuerKey)
    }
}

public extension PaymentDetails {
    private static let nameKey = "sepa.ownerName"
    private static let ibanKey = "sepa.ibanNumber"
    
    /// Fill details for the SEPA transaction.
    public func fillSepa(name: String, iban: String) {
        setDetail(value: name, forKey: PaymentDetails.nameKey)
        setDetail(value: iban, forKey: PaymentDetails.ibanKey)
    }
}
