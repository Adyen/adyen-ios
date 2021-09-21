//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A form item into which a card number is entered.
internal final class FormCardNumberItem: FormTextItem, Observer {
    
    private static let binLength = 12

    private let cardNumberFormatter = CardNumberFormatter()

    /// The supported card types.
    internal let supportedCardTypes: [CardType]
    
    /// The card type logos displayed in the form item.
    internal let cardTypeLogos: [CardTypeLogo]
    
    /// The observable of the card's BIN value.
    /// The value contains up to 6 first digits of card' PAN.
    @Observable("") internal var binValue: String
    
    /// Current brand detected for the entered bin.
    @Observable(nil) internal private(set) var currentBrand: CardBrand?
    
    /// Determines whether validation includes luhn check.
    internal var luhnCheckEnabled: Bool = true {
        didSet {
            validator = CardNumberValidator(isLuhnCheckEnabled: luhnCheckEnabled,
                                            isEnteredBrandSupported: currentBrand?.isSupported ?? true)
        }
    }
    
    /// :nodoc:
    private let localizationParameters: LocalizationParameters?
    
    /// Initializes the form card number item.
    internal init(supportedCardTypes: [CardType],
                  cardTypeLogos: [CardTypeLogo],
                  style: FormTextItemStyle = FormTextItemStyle(),
                  localizationParameters: LocalizationParameters? = nil) {
        self.supportedCardTypes = supportedCardTypes
        
        self.cardTypeLogos = cardTypeLogos
        self.localizationParameters = localizationParameters
        
        super.init(style: style)

        observe(publisher) { [weak self] value in self?.valueDidChange(value) }
        
        title = localizedString(.cardNumberItemTitle, localizationParameters)
        validator = CardNumberValidator(isLuhnCheckEnabled: true, isEnteredBrandSupported: true)
        formatter = cardNumberFormatter
        placeholder = localizedString(.cardNumberItemPlaceholder, localizationParameters)
        validationFailureMessage = localizedString(.cardNumberItemInvalid, localizationParameters)
        keyboardType = .numberPad
    }
    
    // MARK: - Value
    
    internal func valueDidChange(_ value: String) {
        binValue = String(value.prefix(FormCardNumberItem.binLength))
        cardNumberFormatter.cardType = supportedCardTypes.adyen.type(forCardNumber: value)
    }
    
    // MARK: - BuildableFormItem
    
    override internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
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
    
    /// Updates the current brand and the related validation checks.
    internal func update(currentBrand: CardBrand?) {
        // validation message will change based on if brand is supported or not
        // if brand is not supported, allow validation while editing to show the error instantly.
        if currentBrand?.isSupported ?? true {
            allowsValidationWhileEditing = false
            validationFailureMessage = localizedString(.cardNumberItemInvalid, localizationParameters)
        } else {
            allowsValidationWhileEditing = true
            validationFailureMessage = localizedString(.cardNumberItemUnknownBrand, localizationParameters)
        }
        
        validator = CardNumberValidator(isLuhnCheckEnabled: luhnCheckEnabled, isEnteredBrandSupported: currentBrand?.isSupported ?? true)
        self.currentBrand = currentBrand
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
