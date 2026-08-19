//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A card payment method.
public struct CardPaymentMethod: AnyCardPaymentMethod, PaymentMethodDisplayOverridable {
    
    public let type: PaymentMethodType
    
    public let name: String
    
    public let fundingSource: CardFundingSource?
    
    /// An array containing the supported brands, such as `"mc"`, `"visa"`, `"amex"`, `"bcmc"`.
    public let brands: [CardBrand]
    
    // MARK: - Decoding
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(PaymentMethodType.self, forKey: .type)
        self.name = try container.decode(String.self, forKey: .name)
        self.brands = try container.decodeIfPresent([CardBrand].self, forKey: .brands) ?? []
        self.fundingSource = try container.decodeIfPresent(CardFundingSource.self, forKey: .fundingSource)
    }
    
    package func overriddenDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        DisplayInformation(title: name, subtitle: nil, logoName: "card")
    }
    
    internal init(type: PaymentMethodType, name: String, fundingSource: CardFundingSource, brands: [CardBrand]) {
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
public struct StoredCardPaymentMethod: StoredPaymentMethod, AnyCardPaymentMethod, PaymentMethodDisplayOverridable {
    
    public let type: PaymentMethodType
    
    public let name: String
    
    public let identifier: String

    public var brands: [CardBrand] {
        [brand]
    }

    public var fundingSource: CardFundingSource?

    package var descriptionProvider = StoredCardDescriptionProvider()

    package func overriddenDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        let description = descriptionProvider.description(for: self, using: parameters)
        let lastFourSeparated = lastFour.map { String($0) }.joined(separator: ", ")
        let accessibilityLabel = [
            name,
            "\(localizedString(.accessibilityLastFourDigits, parameters)): \(lastFourSeparated)",
            description.isExpired ? description.subtitle : nil
        ]
        .compactMap { $0 }
        .joined(separator: ", ")

        return DisplayInformation(
            title: String.Adyen.securedString + lastFour,
            subtitle: description.subtitle,
            logoName: brand.rawValue,
            accessibilityLabel: accessibilityLabel
        )
    }

    public let supportedShopperInteractions: [ShopperInteraction]
    
    /// The brand of the stored card, such as `"mc"` or `"visa"`.
    public let brand: CardBrand
    
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

package struct StoredCardDescriptionProvider {

    package struct Description {
        package let subtitle: String
        package let isExpired: Bool
    }

    private let currentDate: Date
    private let calendar: Calendar

    package init(currentDate: Date = .now, calendar: Calendar = .current) {
        self.currentDate = currentDate
        self.calendar = calendar
    }

    package func description(
        for card: StoredCardPaymentMethod,
        using parameters: LocalizationParameters?
    ) -> Description {
        guard isExpired(card) else {
            return Description(subtitle: card.name, isExpired: false)
        }

        return Description(
            subtitle: localizedString(.storedPaymentMethodExpired, parameters),
            isExpired: true
        )
    }

    private func isExpired(_ card: StoredCardPaymentMethod) -> Bool {
        guard
            let expiryMonth = Int(card.expiryMonth),
            (1...12).contains(expiryMonth),
            let expiryYear = Int(card.expiryYear),
            let expiryMonthStart = calendar.date(
                from: DateComponents(year: expiryYear, month: expiryMonth)
            ),
            let expiryThreshold = calendar.date(byAdding: .month, value: 1, to: expiryMonthStart)
        else {
            return false
        }

        return currentDate >= expiryThreshold
    }
}

// MARK: - PaymentComponentBuildable

extension CardPaymentMethod: PaymentComponentBuildable {
    package func buildComponent(using builder: any PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
}

extension StoredCardPaymentMethod: PaymentComponentBuildable {
    package func buildComponent(using builder: any PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
}
