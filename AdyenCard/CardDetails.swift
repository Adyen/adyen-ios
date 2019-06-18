//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains the details provided by the card component.
public struct CardDetails: PaymentMethodDetails {
    
    /// The payment method type.
    public let type: String
    
    /// The identifier of the selected stored payment method.
    public let storedPaymentMethodIdentifier: String?
    
    /// The encrypted card number.
    public let encryptedCardNumber: String?
    
    /// The encrypted expiration month.
    public let encryptedExpiryMonth: String?
    
    /// The encrypted expiration year.
    public let encryptedExpiryYear: String?
    
    /// The encrypted security code.
    public let encryptedSecurityCode: String?
    
    /// The name on card.
    public let holderName: String?
    
    /// Initializes the card payment details.
    ///
    /// - Parameters:
    ///   - paymentMethod: The used card payment method.
    ///   - encryptedCard: The encrypted card to read the details from.
    ///   - holderName: The holder name if available.
    internal init(paymentMethod: CardPaymentMethod, encryptedCard: CardEncryptor.EncryptedCard, holderName: String? = nil) {
        self.type = paymentMethod.type
        self.encryptedCardNumber = encryptedCard.number
        self.encryptedExpiryMonth = encryptedCard.expiryMonth
        self.encryptedExpiryYear = encryptedCard.expiryYear
        self.encryptedSecurityCode = encryptedCard.securityCode
        self.holderName = holderName
        self.storedPaymentMethodIdentifier = nil
    }
    
    /// Initializes the card payment details for a stored card payment method.
    ///
    /// - Parameters:
    ///   - paymentMethod: The used stored card payment method.
    ///   - encryptedSecurityCode: The encrypted security code
    internal init(paymentMethod: StoredCardPaymentMethod, encryptedSecurityCode: String) {
        self.type = paymentMethod.type
        self.encryptedSecurityCode = encryptedSecurityCode
        self.storedPaymentMethodIdentifier = paymentMethod.identifier
        self.encryptedCardNumber = nil
        self.encryptedExpiryMonth = nil
        self.encryptedExpiryYear = nil
        self.holderName = nil
    }
    
    // MARK: - Encoding
    
    private enum CodingKeys: String, CodingKey {
        case type
        case storedPaymentMethodIdentifier = "storedPaymentMethodId"
        case encryptedCardNumber
        case encryptedExpiryMonth
        case encryptedExpiryYear
        case encryptedSecurityCode
        case holderName
    }
    
}
