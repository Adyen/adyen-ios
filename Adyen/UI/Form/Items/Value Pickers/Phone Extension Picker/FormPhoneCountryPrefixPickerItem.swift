//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A picker form item for picking phone extensions.
@_spi(AdyenInternal)
public final class FormPhoneCountryPrefixPickerItem: FormPickerItem {
    
    public required init(
        preselectedExtension: PhoneExtension?,
        selectableExtensions: [PhoneExtension],
        validationFailureMessage: String?,
        title: String,
        placeholder: String,
        style: FormTextItemStyle,
        presenter: ViewControllerPresenter?,
        localizationParameters: LocalizationParameters? = nil,
        identifier: String? = nil
    ) {
        let preselectedValue = preselectedExtension?.toFormPickerElement()
        let selectableValues = selectableExtensions.map { $0.toFormPickerElement() }
        
        super.init(
            preselectedValue: preselectedValue,
            selectableValues: selectableValues,
            title: title,
            placeholder: placeholder,
            style: style,
            presenter: presenter,
            localizationParameters: localizationParameters,
            identifier: identifier
        )
        
        self.validationFailureMessage = validationFailureMessage
    }
    
    public func updateValue(with phoneExtension: PhoneExtension?) {
        self.value = phoneExtension?.toFormPickerElement()
    }
    
    override public func resetValue() {
        value = nil
    }
    
    override public func updateValidationFailureMessage() {
        // Nothing to update here
    }
    
    override public func updateFormattedValue() {
        formattedValue = value?.title
    }
}

// MARK: - Region to FormPickerElement

private extension PhoneExtension {
    
    func toFormPickerElement() -> FormPickerElement {
        .init(
            identifier: countryCode,
            icon: nil,
            title: value,
            subtitle: [
                countryCode.adyen.countryFlag,
                countryDisplayName
            ].compactMap { $0 }.joined(separator: " ")
        )
    }
}
