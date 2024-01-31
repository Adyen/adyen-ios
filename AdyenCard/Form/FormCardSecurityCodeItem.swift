//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

/// A form item into which a card's security code (CVC/CVV) is entered.
internal final class FormCardSecurityCodeItem: FormTextItem {

    internal enum DisplayMode {
        case required
        case optional
        case hidden
        
        internal var isVisible: Bool {
            switch self {
            case .required, .optional: return true
            case .hidden: return false
            }
        }
    }
    
    internal var localizationParameters: LocalizationParameters?
    
    @AdyenObservable(nil) internal var selectedCard: CardType?

    @AdyenObservable(.required) internal var displayMode: DisplayMode {
        didSet {
            updateFormState()
        }
    }

    /// Initializes the form security code item.
    internal init(
        style: FormTextItemStyle = FormTextItemStyle(),
        localizationParameters: LocalizationParameters? = nil
    ) {
        self.localizationParameters = localizationParameters
        super.init(style: style)
        
        title = localizedString(.cardCvcItemTitle, localizationParameters)
        validator = securityCodeValidator
        formatter = securityCodeFormatter
        
        validationFailureMessage = localizedString(.cardCvcItemInvalid, localizationParameters)
        keyboardType = .numberPad
    }
    
    internal func updateFormState() {
        switch displayMode {
        case .required:
            title = localizedString(.cardCvcItemTitle, localizationParameters)
            validator = securityCodeValidator
        case .hidden:
            validator = nil
            value = ""
        case .optional:
            // when optional, if user enters anything it should be validated as regular entry.
            title = localizedString(.cardCvcItemTitleOptional, localizationParameters)
            validator = NumericStringValidator(exactLength: 0) || securityCodeValidator
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
