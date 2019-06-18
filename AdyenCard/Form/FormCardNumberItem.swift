//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// A form item into which a card number is entered.
internal final class FormCardNumberItem: FormTextItem {
    
    /// The supported card types.
    internal let supportedCardTypes: [CardType]
    
    /// The card type logos displayed in the form item.
    internal let cardTypeLogos: [CardTypeLogo]
    
    /// Initializes the form card number item.
    internal init(supportedCardTypes: [CardType], environment: Environment) {
        self.supportedCardTypes = supportedCardTypes
        
        let logoURLs = supportedCardTypes.map { LogoURLProvider.logoURL(withName: $0.rawValue, environment: environment) }
        self.cardTypeLogos = logoURLs.prefix(4).map(CardTypeLogo.init) // Limit to a maximum of 4 logos.
        
        super.init()
        
        title = ADYLocalizedString("adyen.card.numberItem.title")
        validator = CardNumberValidator()
        formatter = cardNumberFormatter
        placeholder = ADYLocalizedString("adyen.card.numberItem.placeholder")
        validationFailureMessage = ADYLocalizedString("adyen.card.numberItem.invalid")
        keyboardType = .numberPad
    }
    
    // MARK: - Value
    
    internal override func valueDidChange() {
        super.valueDidChange()
        
        let detectedCardTypes = cardTypeDetector.types(forCardNumber: value)
        for (cardType, logo) in zip(supportedCardTypes, cardTypeLogos) {
            let isVisible = value.isEmpty || detectedCardTypes.contains(cardType)
            logo.isHidden.value = !isVisible
        }
        
        cardNumberFormatter.cardType = detectedCardTypes.first
    }
    
    // MARK: - Private
    
    private let cardNumberFormatter = CardNumberFormatter()
    
    private lazy var cardTypeDetector: CardTypeDetector = {
        let cardTypeDetector = CardTypeDetector()
        cardTypeDetector.detectableTypes = supportedCardTypes
        
        return cardTypeDetector
    }()
    
}

internal extension FormCardNumberItem {
    
    /// Describes a card type logo shown in the card number form item.
    final class CardTypeLogo { // swiftlint:disable:this explicit_acl
        
        /// The URL of the card type logo.
        internal let url: URL
        
        /// Indicates if the card type logo should be hidden.
        internal let isHidden = Observable(false)
        
        /// Initializes the card type logo.
        ///
        /// - Parameter cardType: The card type for which to initialize the logo.
        internal init(url: URL) {
            self.url = url
        }
        
    }
    
}
