//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes a phone number entry form item.
/// :nodoc:
public final class FormPhoneNumberItem: FormTextItem {
    
    /// The phone prefix picker item.
    internal let phonePrefixItem: FormPhoneExtensionPickerItem
    
    /// The phone prefix value.
    public var prefix: String {
        phonePrefixItem.value.phoneExtension
    }
    
    public var phoneNumber: String {
        prefix + value
    }
    
    /// Initializes the phone number item.
    ///
    /// - Parameter selectableValues: The list of values to select from.
    /// - Parameter style: The `FormTextItemStyle` UI style.
    /// - Parameter localizationParameters: Parameters for custom localization, leave it nil to use the default parameters.
    public init(selectableValues: [PhoneExtensionPickerItem],
                style: FormTextItemStyle,
                localizationParameters: LocalizationParameters? = nil) {
        phonePrefixItem = FormPhoneExtensionPickerItem(selectableValues: selectableValues, style: style)
        phonePrefixItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "phoneExtensionPickerItem")
        
        self.style = style
        title = ADYLocalizedString("adyen.phoneNumber.title", localizationParameters)
        placeholder = ADYLocalizedString("adyen.phoneNumber.placeholder", localizationParameters)
        formatter = NumericFormatter()
        validator = NumericStringValidator(minimumLength: 1, maximumLength: 15)
        validationFailureMessage = ADYLocalizedString("adyen.phoneNumber.invalid", localizationParameters)
        keyboardType = .numberPad
    }
    
    /// :nodoc:
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}
