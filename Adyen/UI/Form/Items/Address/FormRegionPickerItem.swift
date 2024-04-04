//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A picker form item for picking regions.
package final class FormRegionPickerItem: FormPickerItem {
    
    public required init(
        preselectedRegion: Region?,
        selectableRegions: [Region],
        validationFailureMessage: String?,
        title: String,
        placeholder: String,
        style: FormTextItemStyle,
        presenter: ViewControllerPresenter?,
        localizationParameters: LocalizationParameters? = nil,
        identifier: String? = nil
    ) {
        let preselectedValue = preselectedRegion?.toFormPickerElement()
        let selectableValues = selectableRegions.map { $0.toFormPickerElement() }
        
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
        self.value = region?.toFormPickerElement()
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
    
    func toFormPickerElement() -> FormPickerElement {
        .init(
            identifier: identifier,
            icon: nil,
            title: name,
            subtitle: identifier
        )
    }
}
