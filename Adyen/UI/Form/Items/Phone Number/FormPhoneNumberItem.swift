//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes a phone number entry form item.
@_spi(AdyenInternal)
public final class FormPhoneNumberItem: FormTextItem {
    
    /// The phone prefix picker item.
    internal let phonePrefixItem: FormPhoneExtensionPickerItem
    
    /// The phone prefix value.
    public var prefix: String {
        phonePrefixItem.value.element.value
    }
    
    public var phoneNumber: String {
        prefix + value
    }
    
    /// Initializes the phone number item.
    ///
    /// - Parameter selectableValues: The list of values to select from.
    /// - Parameter style: The `FormTextItemStyle` UI style.
    /// - Parameter localizationParameters: Parameters for custom localization, leave it nil to use the default parameters.
    public init(phoneNumber: PhoneNumber?,
                selectableValues: [PhoneExtensionPickerItem],
                style: FormTextItemStyle,
                localizationParameters: LocalizationParameters? = nil) {
        
        phonePrefixItem = FormPhoneExtensionPickerItem(
            preselectedValue: selectableValues.preselectedPhoneNumberPrefix(for: phoneNumber),
            selectableValues: selectableValues,
            style: style
        )
        
        super.init(style: style)
        
        phonePrefixItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "phoneExtensionPickerItem")
        value = phoneNumber?.value ?? ""

        title = localizedString(.phoneNumberTitle, localizationParameters)
        placeholder = localizedString(.phoneNumberPlaceholder, localizationParameters)
        formatter = NumericFormatter()
        validator = NumericStringValidator(minimumLength: 1, maximumLength: 15)
        validationFailureMessage = localizedString(.phoneNumberInvalid, localizationParameters)
        keyboardType = .numberPad
    }
    
    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    private static func preselectedPhoneNumberPrefix(
        for phoneNumber: PhoneNumber?,
        in selectableValues: [PhoneExtensionPickerItem]
    ) -> PhoneExtensionPickerItem {
        
        if let matchingCallingCode = selectableValues.first(where: { $0.element.value == phoneNumber?.callingCode }) {
            return matchingCallingCode
        }
        
        if let matchingLocaleRegion = selectableValues.first(where: { $0.identifier == Locale.current.regionCode }) {
            return matchingLocaleRegion
        }
        
        if let firstSelectableValue = selectableValues.first {
            return firstSelectableValue
        }
        
        AdyenAssertion.assertionFailure(message: "Empty list of selectableValues provided")
        return .init(identifier: "", element: .init(value: "+1", countryCode: "US"))
    }
}

private extension [PhoneExtensionPickerItem] {
    
    func preselectedPhoneNumberPrefix(for phoneNumber: PhoneNumber?) -> PhoneExtensionPickerItem {
        
        if let matchingCallingCode = first(where: { $0.element.value == phoneNumber?.callingCode }) {
            return matchingCallingCode
        }
        
        if let matchingLocaleRegion = first(where: { $0.identifier == Locale.current.regionCode }) {
            return matchingLocaleRegion
        }
        
        if let firstSelectableValue = first {
            return firstSelectableValue
        }
        
        AdyenAssertion.assertionFailure(message: "Empty list of selectableValues provided")
        return .init(identifier: "", element: .init(value: "+1", countryCode: "US"))
    }
}
