//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A form item into which a card number is entered.
internal final class FormCardNumberItem: FormTextItem {
    
    private static let binLength = 12

    private let cardNumberFormatter = CardNumberFormatter()

    /// The supported card types.
    internal let supportedCardTypes: [CardType]
    
    /// The card type logos displayed in the form item.
    internal let cardTypeLogos: [CardTypeLogo]
    
    /// The observable of the card's BIN value.
    /// The value contains up to 6 first digits of card' PAN.
    @Observable("") internal var binValue: String
    
    /// :nodoc:
    private let localizationParameters: LocalizationParameters?
    
    /// Initializes the form card number item.
    internal init(supportedCardTypes: [CardType],
                  environment: Environment,
                  style: FormTextItemStyle = FormTextItemStyle(),
                  localizationParameters: LocalizationParameters? = nil) {
        self.supportedCardTypes = supportedCardTypes
        
        self.cardTypeLogos = supportedCardTypes.map {
            CardTypeLogo(url: LogoURLProvider.logoURL(withName: $0.rawValue, environment: environment),
                         type: $0)
        }
        self.localizationParameters = localizationParameters
        
        self.style = style
        
        title = ADYLocalizedString("adyen.card.numberItem.title", localizationParameters)
        validator = CardNumberValidator()
        formatter = cardNumberFormatter
        placeholder = ADYLocalizedString("adyen.card.numberItem.placeholder", localizationParameters)
        validationFailureMessage = ADYLocalizedString("adyen.card.numberItem.invalid", localizationParameters)
        keyboardType = .numberPad
    }
    
    // MARK: - Value
    
    internal func valueDidChange() {
        binValue = String(value.prefix(FormCardNumberItem.binLength))
        cardNumberFormatter.cardType = supportedCardTypes.adyen.type(forCardNumber: value)
    }
    
    // MARK: - BuildableFormItem
    
    internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    /// Show logos of the card types if those types are supported.
    /// - Parameter detectedCards: List of card types to show.
    internal func showLogos(for cardTypes: [CardType]) {
        let detectedCards = Set<CardType>(cardTypes)
        for logo in self.cardTypeLogos {
            let isVisible = detectedCards.contains(logo.type)
            logo.isHidden = !isVisible
        }
    }
    
}

extension FormCardNumberItem {
    
    /// Describes a card type logo shown in the card number form item.
    internal final class CardTypeLogo {

        internal let type: CardType
        
        /// The URL of the card type logo.
        internal let url: URL
        
        /// Indicates if the card type logo should be hidden.
        @Observable(false) internal var isHidden: Bool
        
        /// Initializes the card type logo.
        ///
        /// - Parameter cardType: The card type for which to initialize the logo.
        internal init(url: URL, type: CardType) {
            self.url = url
            self.type = type
        }
        
    }
    
}

extension FormItemViewBuilder {
    internal func build(with item: FormCardNumberItem) -> FormItemView<FormCardNumberItem> {
        FormCardNumberItemView(item: item)
    }
}
