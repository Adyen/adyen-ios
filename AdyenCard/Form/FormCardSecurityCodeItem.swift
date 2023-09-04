//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

/// A form item into which a card's security code (CVC/CVV) is entered.
final class FormCardSecurityCodeItem: FormTextItem {

    enum DisplayMode {
        case required
        case optional
        case hidden

        var isVisible: Bool {
            switch self {
            case .required, .optional: return true
            case .hidden: return false
            }
        }
    }
    
    /// :nodoc:
    var localizationParameters: LocalizationParameters?
    
    /// :nodoc:
    @Observable(nil) var selectedCard: CardType?

    /// :nodoc:
    @Observable(.required) var displayMode: DisplayMode {
        didSet {
            updateFormState()
        }
    }

    /// Initializes the form security code item.
    init(style: FormTextItemStyle = FormTextItemStyle(),
         localizationParameters: LocalizationParameters? = nil) {
        self.localizationParameters = localizationParameters
        super.init(style: style)
        
        title = localizedString(.cardCvcItemTitle, localizationParameters)
        validator = securityCodeValidator
        formatter = securityCodeFormatter
        
        validationFailureMessage = localizedString(.cardCvcItemInvalid, localizationParameters)
        keyboardType = .numberPad
    }

    func updateFormState() {
 
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
    
    override func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    private lazy var securityCodeFormatter = CardSecurityCodeFormatter(publisher: $selectedCard)
    private lazy var securityCodeValidator = CardSecurityCodeValidator(publisher: $selectedCard)
}

extension FormItemViewBuilder {
    func build(with item: FormCardSecurityCodeItem) -> FormItemView<FormCardSecurityCodeItem> {
        FormCardSecurityCodeItemView(item: item)
    }
}
