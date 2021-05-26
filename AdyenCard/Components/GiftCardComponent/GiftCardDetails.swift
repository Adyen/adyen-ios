//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Contains the details provided by the card component.
public struct GiftCardDetails: PaymentMethodDetails {

    /// The payment method type.
    public let type: String

    /// The encrypted card number.
    public let encryptedCardNumber: String

    /// The encrypted security code.
    public let encryptedSecurityCode: String

    /// The gift card brand.
    public let brand: String

    /// Initializes the card payment details.
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

    // MARK: - Encoding

    private enum CodingKeys: String, CodingKey {
        case type
        case encryptedCardNumber
        case encryptedSecurityCode
        case brand
    }

}
