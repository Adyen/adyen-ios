//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// Describes the methods for managing card type change.
internal protocol CardTypeChangeDelegate: class {
    func cardTypeDidChange(type: CardType?)
}

/// A form item into which a card number is entered.
internal final class FormCardNumberItem: FormTextItem {
    
    /// The supported card types.
    internal let supportedCardTypes: [CardType]
    
    /// The card type logos displayed in the form item.
    internal let cardTypeLogos: [CardTypeLogo]
    
    /// The delegate for managing card type change
    internal weak var delegate: CardTypeChangeDelegate?
    
    /// :nodoc:
    private let localizationParameters: LocalizationParameters?
    
    /// Initializes the form card number item.
    internal init(supportedCardTypes: [CardType],
                  environment: Environment,
                  style: FormTextItemStyle = FormTextItemStyle(),
                  localizationParameters: LocalizationParameters? = nil) {
        self.supportedCardTypes = supportedCardTypes
        
        let logoURLs = supportedCardTypes.map { LogoURLProvider.logoURL(withName: $0.rawValue, environment: environment) }
        self.cardTypeLogos = logoURLs.map(CardTypeLogo.init)
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
        let detectedCardTypes = cardTypeDetector.types(forCardNumber: value)
        for (cardType, logo) in zip(supportedCardTypes, cardTypeLogos) {
            let isVisible = value.isEmpty || detectedCardTypes.contains(cardType)
            logo.isHidden.value = !isVisible
        }
        
        cardNumberFormatter.cardType = detectedCardTypes.first
        delegate?.cardTypeDidChange(type: detectedCardTypes.count > 1 ? nil : detectedCardTypes.first)
    }
    
    // MARK: - BuildableFormItem
    
    internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    // MARK: - Private
    
    private let cardNumberFormatter = CardNumberFormatter()
    
    private lazy var cardTypeDetector: CardTypeDetector = {
        let cardTypeDetector = CardTypeDetector()
        cardTypeDetector.detectableTypes = supportedCardTypes
        
        return cardTypeDetector
    }()
    
}

extension FormCardNumberItem {
    
    /// Describes a card type logo shown in the card number form item.
    internal final class CardTypeLogo {
        
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

extension FormItemViewBuilder {
    internal func build(with item: FormCardNumberItem) -> FormItemView<FormCardNumberItem> {
        FormCardNumberItemView(item: item)
    }
}
