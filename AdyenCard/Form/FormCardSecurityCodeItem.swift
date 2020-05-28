//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// A form item into which a card's security code (CVC/CVV) is entered.
internal final class FormCardSecurityCodeItem: FormTextItem {
    
    /// :nodoc:
    internal let localizationParameters: LocalizationParameters?
    
    /// :nodoc:
    internal var selectedCard = Observable<CardType?>(nil)
    
    /// Initializes the form card number item.
    internal init(environment: Environment,
                  style: FormTextItemStyle = FormTextItemStyle(),
                  localizationParameters: LocalizationParameters? = nil) {
        self.localizationParameters = localizationParameters
        self.style = style
        
        title = ADYLocalizedString("adyen.card.cvcItem.title", localizationParameters)
        validator = securityCodeValidator
        formatter = securityCodeFormatter
        
        validationFailureMessage = ADYLocalizedString("adyen.card.cvcItem.invalid", localizationParameters)
        keyboardType = .numberPad
    }
    
    internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    private lazy var securityCodeFormatter = CardSecurityCodeFormatter(publisher: selectedCard)
    private lazy var securityCodeValidator = CardSecurityCodeValidator(publisher: selectedCard)
}

extension FormCardSecurityCodeItem: CardTypeChangeDelegate {
    internal func cardTypeDidChange(type: CardType?) {
        selectedCard.value = type
    }
}

extension FormItemViewBuilder {
    internal func build(with item: FormCardSecurityCodeItem) -> FormItemView<FormCardSecurityCodeItem> {
        FormCardSecurityCodeItemView(item: item)
    }
}
