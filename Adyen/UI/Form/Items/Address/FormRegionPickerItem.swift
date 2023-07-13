//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An address form item for address lookup.
@_spi(AdyenInternal)
public final class FormRegionPickerItem: FormPickerItem {
    
    private let shouldShowCountryFlags: Bool
    
    public required init(
        preselectedRegion: Region?,
        selectableRegions: [Region],
        shouldShowCountryFlags: Bool,
        validationFailureMessage: String?,
        title: String,
        placeholder: String,
        style: FormTextItemStyle,
        localizationParameters: LocalizationParameters? = nil,
        identifier: String? = nil
    ) {
        let preselectedValue = preselectedRegion?.toFormPickable(shouldShowCountryFlag: shouldShowCountryFlags)
        let selectableValues = selectableRegions.map { $0.toFormPickable(shouldShowCountryFlag: shouldShowCountryFlags) }
        
        self.shouldShowCountryFlags = shouldShowCountryFlags
        
        super.init(
            preselectedValue: preselectedValue,
            selectableValues: selectableValues,
            title: title,
            placeholder: placeholder,
            style: style,
            localizationParameters: localizationParameters,
            identifier: identifier
        )
        
        self.validationFailureMessage = validationFailureMessage
    }
    
    public func updateValue(with region: Region?) {
        self.value = region?.toFormPickable(shouldShowCountryFlag: shouldShowCountryFlags)
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

// MARK: - Region to FormPickable

private extension Region {
    
    func toFormPickable(shouldShowCountryFlag: Bool) -> FormPickable {
        .init(
            identifier: identifier,
            icon: nil,
            title: name,
            subtitle: subtitle(shouldShowCountryFlag: shouldShowCountryFlag)
        )
    }
    
    func subtitle(shouldShowCountryFlag: Bool) -> String {
        if shouldShowCountryFlag, let countryFlag = identifier.adyen.countryFlag {
            return "\(countryFlag) \(identifier)"
        }
        
        return identifier
    }
}
