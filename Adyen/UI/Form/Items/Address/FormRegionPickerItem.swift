//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A picker form item for picking regions.
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
        presenter: ViewControllerPresenter?,
        localizationParameters: LocalizationParameters? = nil,
        identifier: String? = nil
    ) {
        let preselectedValue = preselectedRegion?.toFormPickerElement(shouldShowCountryFlag: shouldShowCountryFlags)
        let selectableValues = selectableRegions.map { $0.toFormPickerElement(shouldShowCountryFlag: shouldShowCountryFlags) }
        
        self.shouldShowCountryFlags = shouldShowCountryFlags
        
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
    
    public func updateValue(with region: Region?) {
        self.value = region?.toFormPickerElement(shouldShowCountryFlag: shouldShowCountryFlags)
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

private extension Region {
    
    func toFormPickerElement(shouldShowCountryFlag: Bool) -> FormPickerElement {
        .init(
            identifier: identifier,
            icon: nil,
            title: name,
            subtitle: subtitle(showingCountryFlag: shouldShowCountryFlag)
        )
    }
    
    func subtitle(showingCountryFlag: Bool) -> String {
        if showingCountryFlag, let countryFlag = identifier.adyen.countryFlag {
            return "\(countryFlag) \(identifier)"
        }
        
        return identifier
    }
}
