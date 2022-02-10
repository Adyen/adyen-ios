//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes the Card brand.
public struct CardBrand: Decodable {
    
    /// Indicates the requirement level of a field.
    internal enum RequirementPolicy: String, Decodable {

        /// Field is required.
        case required

        /// Field is optional.
        case optional

        /// Field should not be asked.
        case hidden
    }

    /// Indicates the card brand type.
    public let type: CardType

    /// Indicates whether its supported by the merchant or not.
    public let isSupported: Bool

    /// Indicates the cvc policy of the brand.
    internal let cvcPolicy: RequirementPolicy
    
    /// Indicates the expiry date policy of the brand.
    internal let expiryDatePolicy: RequirementPolicy

    /// Indicates whether Luhn check applies to card numbers of this brand.
    internal let isLuhnCheckEnabled: Bool
    
    /// Indicates whether to show social security number field or not.
    internal let showsSocialSecurityNumber: Bool
    
    /// The length of the PAN of the card brand.
    internal let panLength: Int?
    
    private enum Constants {
        static let plccText = "plcc"
        static let cbccText = "cbcc"
    }

    /// Initializes a CardBrand.
    ///
    /// - Parameters:
    ///   - type: Indicates the card brand type.
    ///   - isSupported: Indicates whether its supported by the merchant or not.
    ///   - cvcPolicy: Indicates the cvc policy of the brand.
    ///   - expiryDatePolicy: Indicates the expiry date policy of the brand.
    ///   - isLuhnCheckEnabled: Indicates whether Luhn check applies to card numbers of this brand.
    ///   - showsSocialSecurityNumber: Indicates whether to show social security number field or not.
    internal init(type: CardType,
                  isSupported: Bool = true,
                  cvcPolicy: RequirementPolicy = .required,
                  expiryDatePolicy: RequirementPolicy = .required,
                  isLuhnCheckEnabled: Bool = true,
                  showSocialSecurityNumber: Bool = false,
                  panLength: Int? = nil) {
        self.type = type
        self.isSupported = isSupported
        self.cvcPolicy = cvcPolicy
        self.expiryDatePolicy = expiryDatePolicy
        self.isLuhnCheckEnabled = isLuhnCheckEnabled
        self.showsSocialSecurityNumber = showSocialSecurityNumber
        self.panLength = panLength
    }

    private enum CodingKeys: String, CodingKey {
        case type = "brand"
        case isSupported = "supported"
        case cvcPolicy
        case isLuhnCheckEnabled = "enableLuhnCheck"
        case showsSocialSecurityNumber = "showSocialSecurityNumber"
        case expiryDatePolicy
        case panLength
    }
    
    internal var isCVCOptional: Bool {
        switch cvcPolicy {
        case .optional, .hidden:
            return true
        case .required:
            return false
        }
    }
    
    internal var isExpiryDateOptional: Bool {
        switch expiryDatePolicy {
        case .optional, .hidden:
            return true
        case .required:
            return false
        }
    }
    
    /// Determines if the brand is a private labeled card.
    internal var isPrivateLabeled: Bool {
        type.rawValue.contains(Constants.plccText) || type.rawValue.contains(Constants.cbccText)
    }
}

/// :nodoc:
extension CardBrand: Equatable {}
