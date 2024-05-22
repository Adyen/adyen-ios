//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

@_spi(AdyenInternal)
extension PhoneExtension: FormPickable {
    public var identifier: String { countryCode }
    public var icon: UIImage? { nil }
    public var title: String { value }
    public var subtitle: String? { countryDisplayName }
    public var trailingText: String? { nil }
}

/// A picker form item for picking regions.
@_spi(AdyenInternal)
public final class FormPhoneExtensionPickerItem: FormPickerItem<PhoneExtension> {
    
    public required init(
        preselectedExtension: PhoneExtension?,
        selectableExtensions: [PhoneExtension],
        validationFailureMessage: String?,
        style: FormTextItemStyle,
        presenter: ViewControllerPresenter,
        localizationParameters: LocalizationParameters? = nil,
        identifier: String? = nil
    ) {
        super.init(
            preselectedValue: preselectedExtension,
            selectableValues: selectableExtensions,
            title: localizedString(.telephonePrefix, localizationParameters),
            placeholder: "",
            style: style,
            presenter: presenter,
            localizationParameters: localizationParameters,
            identifier: identifier
        )
        
        self.validationFailureMessage = validationFailureMessage
    }
    
    override public func resetValue() {
        value = nil
    }
    
    override public func updateValidationFailureMessage() {
        // Nothing to update here
    }
    
    override public func updateFormattedValue() {
        // Not needed in this case
    }
    
    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
}
