//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import struct Adyen.LocalizationKey
import AdyenUI
@_spi(AdyenInternal) import class AdyenUI.FormTextInputItem

/// A form item into which a card's security code (CVC/CVV) is entered.
internal final class FormCardSecurityCodeItem: FormTextInputItem, AdyenObserver {

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
    
    @AdyenObservable(nil) internal var selectedCard: CardBrand?

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
        
        title = localizedString(.cardSecurityCodeLabel, localizationParameters)
        validator = securityCodeValidator
        formatter = securityCodeFormatter
        
        keyboardType = .numberPad

        observe(publisher) { [weak self] _ in
            self?.updateValidationFailureMessage()
        }
        observe($selectedCard) { [weak self] _ in
            self?.updateHint()
            self?.updateValidationFailureMessage()
        }

        updateHint()
        updateValidationFailureMessage()
    }
    
    internal func updateFormState() {
        switch displayMode {
        case .required:
            title = localizedString(.cardSecurityCodeLabel, localizationParameters)
            validator = securityCodeValidator
        case .hidden:
            validator = nil
            value = ""
        case .optional:
            // when optional, if user enters anything it should be validated as regular entry.
            title = localizedString(.cardCvcItemTitleOptional, localizationParameters)
            validator = NumericStringValidator(exactLength: 0) || securityCodeValidator
        }
        updateValidationFailureMessage()
    }

    override internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    private lazy var securityCodeFormatter = CardSecurityCodeFormatter(publisher: $selectedCard)
    private lazy var securityCodeValidator = CardSecurityCodeValidator(publisher: $selectedCard)

    /// Recomputes `validationFailureMessage` from the item's current validation status,
    /// localized for the selected brand's expected security code length.
    private func updateValidationFailureMessage() {
        validationFailureMessage = securityCodeValidationFailureMessage()
    }

    private func securityCodeValidationFailureMessage() -> String? {
        guard !isValid(),
              let error = securityCodeValidator.validate(value).validationError as? CardValidationError else {
            return nil
        }
        return CardSecurityCodeStrings.validationMessage(
            for: error,
            brand: selectedCard,
            localizationParameters: localizationParameters
        )
    }

    private func updateHint() {
        // Set placeholder on item - it will be shown in footer label reactively
        placeholder = CardSecurityCodeStrings.hint(for: selectedCard, localizationParameters: localizationParameters)
    }
}

extension FormItemViewBuilder {
    internal func build(with item: FormCardSecurityCodeItem) -> FormItemView<FormCardSecurityCodeItem> {
        FormCardSecurityCodeItemView(item: item, theme: theme)
    }
}
