//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

// TODO: Replace FormRegionPickerItem with this and rename!

extension Region: FormPickable {
    
    public var displayTitle: String { name }
    public var displaySubtitle: String? { identifier }
}

/// An address form item for address lookup.
@_spi(AdyenInternal)
public final class FormCountryPickerItem: FormPickerItem<Region> {
    
    override public init(
        prefillValue: Region?,
        selectableValues: [Region],
        title: String,
        placeholder: String,
        style: FormTextItemStyle,
        localizationParameters: LocalizationParameters? = nil,
        identifier: String? = nil
    ) {
        super.init(
            prefillValue: prefillValue,
            selectableValues: selectableValues,
            title: title,
            placeholder: placeholder,
            style: style,
            localizationParameters: localizationParameters,
            identifier: identifier
        )
    }
    
    override public func resetValue() {
        value = nil
    }
    
    override public func isValid() -> Bool {
        if isOptional { return true }
        print(#function)
        return false
    }
    
    override public func updateValidationFailureMessage() {
        print(#function)
    }
    
    override public func updateFormattedValue() {
        formattedValue = value?.name
    }
}
