//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A card payment method.
public struct CardPaymentMethod: PaymentMethod {
    
    /// :nodoc:
    public let type: String
    
    /// :nodoc:
    public let name: String
    
    /// :nodoc:
    public var displayInformation: DisplayInformation {
        return DisplayInformation(title: name, subtitle: nil, logoName: "card")
    }
    
    /// An array containing the supported brands, such as `"mc"`, `"visa"`, `"amex"`.
    public let brands: [String]
    
    // MARK: - Decoding
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        self.name = try container.decode(String.self, forKey: .name)
        self.brands = try container.decodeIfPresent([String].self, forKey: .brands) ?? []
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case brands
    }
    
}

/// A stored card.
public struct StoredCardPaymentMethod: StoredPaymentMethod {
    
    /// :nodoc:
    public let type: String
    
    /// :nodoc:
    public let identifier: String
    
    /// :nodoc:
    public let name: String
    
    /// :nodoc:
    public var displayInformation: DisplayInformation {
        let expireDate = expiryMonth + "/" + expiryYear
        
        return DisplayInformation(title: "••••\u{00a0}" + lastFour,
                                  subtitle: ADYLocalizedString("adyen.card.stored.expires", expireDate),
                                  logoName: brand)
    }
    
    /// :nodoc:
    public let supportedShopperInteractions: [ShopperInteraction]
    
    /// The brand of the stored card, such as `"mc"` or `"visa"`.
    public let brand: String
    
    /// The last four digits of the card number.
    public let lastFour: String
    
    /// The month the card expires.
    public let expiryMonth: String
    
    /// The year the card expires.
    public let expiryYear: String
    
    /// The name of the cardholder.
    public let holderName: String?
    
    // MARK: - Decoding
    
    private enum CodingKeys: String, CodingKey {
        case type
        case identifier = "id"
        case name
        case brand
        case lastFour
        case expiryMonth
        case expiryYear
        case holderName
        case supportedShopperInteractions
    }
    
}
