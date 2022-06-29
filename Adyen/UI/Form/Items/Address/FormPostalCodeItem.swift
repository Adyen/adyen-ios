//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
public final class FormPostalCodeItem: FormTextItem {

    internal var localizationParameters: LocalizationParameters?

    /// Initializes the form postal code item.
    public init(style: FormTextItemStyle = FormTextItemStyle(),
                localizationParameters: LocalizationParameters? = nil) {
        self.localizationParameters = localizationParameters
        super.init(style: style)

        title = localizedString(.postalCodeFieldTitle, localizationParameters)
        placeholder = localizedString(.postalCodeFieldPlaceholder, localizationParameters)
        validator = LengthValidator(minimumLength: 2, maximumLength: 30)
        validationFailureMessage = localizedString(.validationAlertTitle, localizationParameters)
        contentType = .postalCode
    }

    public func updateOptionalStatus(isOptional: Bool) {
        // when optional, if user enters anything it should be validated as regular entry.
        if isOptional {
            title = localizedString(.postalCodeFieldTitle,
                                    localizationParameters) + " " + localizedString(.fieldTitleOptional,
                                                                                    localizationParameters)
            validator = LengthValidator(minimumLength: 0, maximumLength: 30)
        } else {
            title = localizedString(.postalCodeFieldTitle, localizationParameters)
            validator = LengthValidator(minimumLength: 2, maximumLength: 30)
        }
    }

    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
}
