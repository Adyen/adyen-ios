//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A card payment method.
public struct CardPaymentMethod: AnyCardPaymentMethod {
    
    public let type: PaymentMethodType
    
    public let name: String
    
    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?
    
    public let fundingSource: CardFundingSource?
    
    /// An array containing the supported brands, such as `"mc"`, `"visa"`, `"amex"`, `"bcmc"`.
    public let brands: [CardType]
    
    // MARK: - Decoding
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(PaymentMethodType.self, forKey: .type)
        self.name = try container.decode(String.self, forKey: .name)
        self.brands = try container.decodeIfPresent([CardType].self, forKey: .brands) ?? []
        self.fundingSource = try container.decodeIfPresent(CardFundingSource.self, forKey: .fundingSource)
    }
    
    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    public func defaultDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        DisplayInformation(title: name, subtitle: nil, logoName: "card")
    }
    
    internal init(type: PaymentMethodType, name: String, fundingSource: CardFundingSource, brands: [CardType]) {
        self.type = type
        self.name = name
        self.brands = brands
        self.fundingSource = fundingSource
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case brands
        case fundingSource
    }
    
}

/// A stored card.
public struct StoredCardPaymentMethod: StoredPaymentMethod, AnyCardPaymentMethod {
    
    public let type: PaymentMethodType
    
    public let name: String
    
    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?

    public let identifier: String

    public var brands: [CardType] { [brand] }

    public var fundingSource: CardFundingSource?

    public func defaultDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        let expireDate = expiryMonth + "/" + String(expiryYear.suffix(2))
        
        return DisplayInformation(title: String.Adyen.securedString + lastFour,
                                  subtitle: localizedString(.cardStoredExpires, parameters, expireDate),
                                  logoName: brand.rawValue)
    }
    
    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    public let supportedShopperInteractions: [ShopperInteraction]
    
    /// The brand of the stored card, such as `"mc"` or `"visa"`.
    public let brand: CardType
    
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
        case fundingSource
    }
    
}
