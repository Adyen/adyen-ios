//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes the Card brand.
public struct CardBrand: Decodable {

    /// Indicates the card brand type.
    public let type: CardType

    /// Indicates whether its supported by the merchant or not.
    public let isSupported: Bool

    /// Indicates the cvc policy of the brand.
    internal let cvcPolicy: CVCPolicy

    /// Indicates the cvc policy of the brand.
    public enum CVCPolicy: String, Decodable {

        /// CVC is required.
        case required

        /// CVC is optional.
        case optional

        /// CVC should be hidden.
        case hidden
    }

    /// Indicates whether Luhn check applies to card numbers of this brand.
    internal let isLuhnCheckEnabled: Bool

    /// Indicates whether to show the expiry date field.
    internal let showsExpiryDate: Bool

    /// Initializes a CardBrand.
    ///
    /// - Parameters:
    ///   - type: Indicates the card brand type.
    ///   - isSupported: Indicates whether its supported by the merchant or not.
    ///   - cvcPolicy: Indicates the cvc policy of the brand.
    ///   - isLuhnCheckEnabled: Indicates whether Luhn check applies to card numbers of this brand.
    ///   - showsExpiryDate: Indicates whether to show the expiry date field.
    internal init(type: CardType,
                  isSupported: Bool = true,
                  cvcPolicy: CVCPolicy = .required,
                  isLuhnCheckEnabled: Bool = true,
                  showsExpiryDate: Bool = true) {
        self.type = type
        self.isSupported = isSupported
        self.cvcPolicy = cvcPolicy
        self.isLuhnCheckEnabled = isLuhnCheckEnabled
        self.showsExpiryDate = showsExpiryDate
    }

    private enum CodingKeys: String, CodingKey {
        case type = "brand"
        case isSupported = "supported"
        case cvcPolicy
        case isLuhnCheckEnabled = "enableLuhnCheck"
        case showsExpiryDate = "showExpiryDate"
    }
}

/// :nodoc:
extension CardBrand: Equatable {}
