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
    public let cardNumber: String

    /// The encrypted security code.
    public let securityCode: String

    /// The gift card brand
    public let brand: String

    /// Initializes the card payment details.
    ///
    /// - Parameters:
    ///   - paymentMethod: The used gift card payment method.
    ///   - card: The card to read the details from.
    public init(paymentMethod: GiftCardPaymentMethod, cardNumber: String, securityCode: String) {
        self.type = paymentMethod.type
        self.brand = paymentMethod.brand
        self.cardNumber = cardNumber
        self.securityCode = securityCode
    }

    // MARK: - Encoding

    private enum CodingKeys: String, CodingKey {
        case type
        case cardNumber = "number"
        case securityCode = "cvc"
        case brand
    }

}
