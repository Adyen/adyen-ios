//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains encrypted card information.
public struct EncryptedCard {

    /// The encrypted card number.
    public let number: String?

    /// The card's encrypted security code.
    public let securityCode: String?

    /// The encrypted month the card expires.
    public let expiryMonth: String?

    /// The encrypted year the card expires.
    public let expiryYear: String?
}
