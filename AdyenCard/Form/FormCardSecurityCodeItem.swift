//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

/// A form item into which a card's security code (CVC/CVV) is entered.
internal final class FormCardSecurityCodeItem: FormTextItem {

    /// :nodoc:
    internal var localizationParameters: LocalizationParameters?
    
    /// :nodoc:
    @Observable(nil) internal var selectedCard: CardType?

    /// :nodoc:
    @Observable(false) internal var isOptional: Bool {
        didSet {
            updateFormState()
        }
    }

    /// Initializes the form card number item.
    internal init(style: FormTextItemStyle = FormTextItemStyle(),
                  localizationParameters: LocalizationParameters? = nil) {
        self.localizationParameters = localizationParameters
        super.init(style: style)
        
        title = localizedString(.cardCvcItemTitle, localizationParameters)
        validator = securityCodeValidator
        formatter = securityCodeFormatter
        
        validationFailureMessage = localizedString(.cardCvcItemInvalid, localizationParameters)
        keyboardType = .numberPad
    }

    internal func updateFormState() {
        // when optional, if user enters anything it should be validated as regular entry.
        if isOptional {
            title = localizedString(.cardCvcItemTitleOptional, localizationParameters)
            validator = NumericStringValidator(exactLength: 0) || securityCodeValidator
        } else {
            title = localizedString(.cardCvcItemTitle, localizationParameters)
            validator = securityCodeValidator
        }
    }
    
    override internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    private lazy var securityCodeFormatter = CardSecurityCodeFormatter(publisher: $selectedCard)
    private lazy var securityCodeValidator = CardSecurityCodeValidator(publisher: $selectedCard)
}

extension FormItemViewBuilder {
    internal func build(with item: FormCardSecurityCodeItem) -> FormItemView<FormCardSecurityCodeItem> {
        FormCardSecurityCodeItemView(item: item)
    }
}

extension Array where Element == CardBrand {
    internal var isCVCOptional: Bool {
        guard !isEmpty else { return false }
        return allSatisfy { brand in
            switch brand.cvcPolicy {
            case .optional, .hidden:
                return true
            default:
                return false
            }
        }
    }
    
    /// At the moment, due to UI concerns, we won't hide cvc/exp date fields even when response is hidden
    /// We will make them optional.
    internal var isExpiryDateOptional: Bool {
        guard !isEmpty else { return false }
        return allSatisfy { brand in
            switch brand.expiryDatePolicy {
            case .optional, .hidden:
                return true
            default:
                return false
            }
        }
    }
    
    /// If any of the brands have `socialSecurityNumberRequired` as true, then this will return true.
    internal var socialSecurityNumberRequired: Bool {
        contains { $0.showsSocialSecurityNumber }
    }
    
    /// If all the brands require luhn check, returns `true`. Even if one brand requires to skip it, returns `false`
    internal var luhnCheckRequired: Bool {
        allSatisfy(\.isLuhnCheckEnabled)
    }
}
