//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

/// A form item into which card expiry date is entered, formatted and validated.
internal final class FormCardExpiryDateItem: FormTextItem, Hidable {
    
    /// :nodoc:
    public var isHidden: AdyenObservable<Bool> = AdyenObservable(false)
    
    /// :nodoc:
    internal var localizationParameters: LocalizationParameters?
    
    /// Flag determining this forms state. Validation changes based on this.
    internal var isOptional: Bool = false {
        didSet {
            updateFormState()
        }
    }
    
    private let expiryDateValidator = CardExpiryDateValidator()
    
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
    
    /// :nodoc:
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
