//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains the information of a card that is yet to be encrypted.
public struct Card {

    /// The card number.
    public var number: String?

    /// The card's security code.
    public var securityCode: String?

    /// The month the card expires.
    public var expiryMonth: String?

    /// The year the card expires.
    public var expiryYear: String?

    /// The name of the card holder.
    public var holder: String?

    /// Create new unencrypted card from collected strings.
    /// - Parameters:
    ///   - number: The card number.
    ///   - securityCode: The card's security code.
    ///   - expiryMonth: The month the card expires.
    ///   - expiryYear: The year the card expires.
    ///   - holder: The name of the card holder.
    public init(number: String? = nil, securityCode: String? = nil, expiryMonth: String? = nil, expiryYear: String? = nil, holder: String? = nil) {
        self.number = number
        self.securityCode = securityCode
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.holder = holder
    }

    internal var isEmpty: Bool {
        [number, securityCode, expiryYear, expiryMonth].allSatisfy { $0 == nil }
    }

}
