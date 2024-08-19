//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

/// A form item into which card expiry date is entered, formatted and validated.
internal final class FormCardExpiryDateItem: FormTextItem {
    
    internal var localizationParameters: LocalizationParameters?
    
    /// Flag determining this forms state. Validation changes based on this.
    internal var isOptional: Bool = false {
        didSet {
            updateFormState()
        }
    }
    
    private let expiryDateValidator = CardExpiryDateValidator()
    
    /// Returns the month part of the expiry date item
    internal var expiryMonth: String? {
        guard let nonEmptyValue else { return nil }
        return nonEmptyValue.adyen[0...1]
    }
    
    /// Returns the year part of the expiry date item by prefixing it with `"20"`
    internal var expiryYear: String? {
        guard let nonEmptyValue else { return nil }
        return "20" + nonEmptyValue.adyen[2...3]
    }
    
    /// Initiate new instance of `FormTextInputItem`
    /// - Parameter style: The `FormTextItemStyle` UI style.
    internal init(style: FormTextItemStyle = FormTextItemStyle(),
                  localizationParameters: LocalizationParameters? = nil) {
        super.init(style: style)
        title = localizedString(.cardExpiryItemTitle, localizationParameters)
        placeholder = localizedString(.cardExpiryItemPlaceholder, localizationParameters)
        formatter = CardExpiryDateFormatter()
        validator = expiryDateValidator
        validationFailureMessage = localizedString(.cardExpiryItemInvalid, localizationParameters)
        keyboardType = .numberPad
    }
    
    override internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    private func updateFormState() {
        // when optional, if user enters anything it should be validated as regular entry.
        if isOptional {
            title = localizedString(.cardExpiryItemTitleOptional, localizationParameters)
            validator = NumericStringValidator(exactLength: 0) || expiryDateValidator
        } else {
            title = localizedString(.cardExpiryItemTitle, localizationParameters)
            validator = expiryDateValidator
        }
    }
    
}

extension FormItemViewBuilder {
    internal func build(with item: FormCardExpiryDateItem) -> FormItemView<FormCardExpiryDateItem> {
        FormTextItemView<FormCardExpiryDateItem>(item: item)
    }
}
