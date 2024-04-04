//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenEncryption)
    import AdyenEncryption
#endif
import Foundation

/// Contains the details provided by the gift card component.
public struct GiftCardDetails: PartialPaymentMethodDetails {
    
    @_spi(AdyenInternal)
    public var checkoutAttemptId: String?

    /// The payment method type.
    public let type: PaymentMethodType

    /// The encrypted card number.
    public let encryptedCardNumber: String

    /// The encrypted security code.
    public let encryptedSecurityCode: String

    /// The gift card brand.
    public let brand: String

    /// Initializes the gift card payment details.
    ///
    /// - Parameters:
    ///   - paymentMethod: The used gift card payment method.
    ///   - encryptedCardNumber: The encrypted card number.
    ///   - encryptedSecurityCode: The encrypted security code.
    public init(paymentMethod: GiftCardPaymentMethod, encryptedCardNumber: String, encryptedSecurityCode: String) {
        self.type = paymentMethod.type
        self.brand = paymentMethod.brand
        self.encryptedCardNumber = encryptedCardNumber
        self.encryptedSecurityCode = encryptedSecurityCode
    }
    
    /// Initializes the gift card payment details.
    ///
    /// - Parameters:
    ///   - paymentMethod: The used gift card payment method.
    ///   - encryptedCard: The encrypted card .
    public init(paymentMethod: GiftCardPaymentMethod, encryptedCard: EncryptedCard) throws {
        guard let number = encryptedCard.number,
              let securityCode = encryptedCard.securityCode else { throw GiftCardComponent.Error.cardEncryptionFailed }
        
        self.type = paymentMethod.type
        self.brand = paymentMethod.brand
        self.encryptedCardNumber = number
        self.encryptedSecurityCode = securityCode
    }

    // MARK: - Encoding

    private enum CodingKeys: String, CodingKey {
        case type
        case encryptedCardNumber
        case encryptedSecurityCode
        case brand
    }

}
