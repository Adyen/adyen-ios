//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public final class FormPostalCodeItem: FormTextItem {
    
    private enum Constants {
        static let minLength = 2
        static let maxLength = 30
    }
    
    internal var localizationParameters: LocalizationParameters?

    /// Initializes the form postal code item.
    public init(style: FormTextItemStyle = FormTextItemStyle(),
                localizationParameters: LocalizationParameters? = nil) {
        self.localizationParameters = localizationParameters
        super.init(style: style)
        
        title = localizedString(.postalCodeFieldTitle, localizationParameters)
        placeholder = localizedString(.postalCodeFieldPlaceholder, localizationParameters)
        validator = PostalCodeValidator(minimumLength: Constants.minLength, maximumLength: Constants.maxLength)
        validationFailureMessage = localizedString(.validationAlertTitle, localizationParameters)
        contentType = .postalCode
    }
    
    public func updateOptionalStatus(isOptional: Bool) {
        // when optional, if user enters anything it should be validated as regular entry.
        if isOptional {
            title = localizedString(.postalCodeFieldTitle,
                                    localizationParameters) + " " + localizedString(.fieldTitleOptional,
                                                                                    localizationParameters)
            validator = PostalCodeValidator(minimumLength: 0, maximumLength: Constants.maxLength)
        } else {
            title = localizedString(.postalCodeFieldTitle, localizationParameters)
            validator = PostalCodeValidator(minimumLength: Constants.minLength, maximumLength: Constants.maxLength)
        }
    }
    
    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
}
