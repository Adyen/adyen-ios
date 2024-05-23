//
// Copyright (c) 2024 Adyen N.V.
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
        phonePrefixItem.value?.value ?? ""
    }
    
    public var phoneNumber: String {
        prefix + value
    }
    
    /// Initializes the phone number item.
    ///
    /// - Parameter selectableValues: The list of values to select from.
    /// - Parameter style: The `FormTextItemStyle` UI style.
    /// - Parameter localizationParameters: Parameters for custom localization, leave it nil to use the default parameters.
    public init(
        phoneNumber: PhoneNumber?,
        selectableValues: [PhoneExtension],
        style: FormTextItemStyle,
        localizationParameters: LocalizationParameters? = nil,
        presenter: WeakReferenceViewControllerPresenter
    ) {
        phonePrefixItem = .init(
            preselectedExtension: selectableValues.preselectedPhoneNumberPrefix(for: phoneNumber),
            selectableExtensions: selectableValues,
            validationFailureMessage: nil,
            style: style,
            presenter: presenter
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
}

private extension [PhoneExtension] {
    
    func preselectedPhoneNumberPrefix(for phoneNumber: PhoneNumber?) -> PhoneExtension {
        
        if let matchingCallingCode = first(where: { $0.value == phoneNumber?.callingCode }) {
            return matchingCallingCode
        }
        
        if let matchingLocaleRegion = first(where: { $0.countryCode == Locale.current.regionCode }) {
            return matchingLocaleRegion
        }
        
        if let firstSelectableValue = first {
            return firstSelectableValue
        }
        
        AdyenAssertion.assertionFailure(message: "Empty list of selectableValues provided")
        return .init(value: "+1", countryCode: "US")
    }
}
