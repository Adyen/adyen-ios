//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenEncryption)
    import AdyenEncryption
#endif
import Foundation

/// Contains the details provided by the card component.
public struct CardDetails: PaymentMethodDetails, ShopperInformation {

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

    /// The card funding source.
    public let fundingSource: CardFundingSource?

    /// The billing address information.
    public let billingAddress: PostalAddress?

    /// The card password (2 digits).
    public let password: String?

    /// The cardholder Birthdate (6 digits in a YYMMDD format) for private cards
    /// or Corporate registration number (10 digits) for corporate cards.
    public let taxNumber: String?

    /// Social security number of the shopper, if required by country.
    public let socialSecurityNumber: String?

    /// The 3DS2 SDK version.
    public let threeDS2SDKVersion: String = threeDS2SdkVersion
    
    /// Brand of the card.
    public let selectedBrand: String?

    /// Initializes the card payment details.
    ///
    /// :nodoc:
    ///
    /// - Parameters:
    ///   - paymentMethod: The used card payment method.
    ///   - encryptedCard: The encrypted card to read the details from.
    ///   - holderName: The holder name if available.
    ///   - selectedBrand: Brand of the card.
    ///   - billingAddress: The billing address information.
    ///   - kcpDetails: The additional details for KCP authentication.
    public init(paymentMethod: AnyCardPaymentMethod,
                encryptedCard: EncryptedCard,
                holderName: String? = nil,
                selectedBrand: String? = nil,
                billingAddress: PostalAddress? = nil,
                kcpDetails: KCPDetails? = nil,
                socialSecurityNumber: String? = nil) {
        self.type = paymentMethod.type
        self.encryptedCardNumber = encryptedCard.number
        self.encryptedExpiryMonth = encryptedCard.expiryMonth
        self.encryptedExpiryYear = encryptedCard.expiryYear
        self.encryptedSecurityCode = encryptedCard.securityCode
        self.holderName = holderName
        self.selectedBrand = selectedBrand
        self.storedPaymentMethodIdentifier = nil
        self.fundingSource = paymentMethod.fundingSource
        self.billingAddress = billingAddress
        self.taxNumber = kcpDetails?.taxNumber
        self.password = kcpDetails?.password
        self.socialSecurityNumber = socialSecurityNumber
    }

    /// Initializes the card payment details for a stored card payment method.
    ///
    /// :nodoc:
    ///
    /// - Parameters:
    ///   - paymentMethod: The used stored card payment method.
    ///   - encryptedSecurityCode: The encrypted security code.
    public init(paymentMethod: StoredCardPaymentMethod, encryptedSecurityCode: String) {
        self.type = paymentMethod.type
        self.encryptedSecurityCode = encryptedSecurityCode
        self.storedPaymentMethodIdentifier = paymentMethod.identifier
        self.encryptedCardNumber = nil
        self.encryptedExpiryMonth = nil
        self.encryptedExpiryYear = nil
        self.holderName = nil
        self.fundingSource = paymentMethod.fundingSource
        self.billingAddress = nil
        self.taxNumber = nil
        self.password = nil
        self.socialSecurityNumber = nil
        self.selectedBrand = nil
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
        case selectedBrand = "brand"
        case fundingSource
        case taxNumber
        case password = "encryptedPassword"
        case threeDS2SDKVersion = "threeDS2SdkVersion"
    }

}
