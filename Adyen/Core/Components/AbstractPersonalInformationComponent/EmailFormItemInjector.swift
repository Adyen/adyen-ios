//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal final class EmailFormItemInjector: FormItemInjector, Localizable {

    internal var localizationParameters: LocalizationParameters?

    internal let style: FormTextItemStyle

    internal var value: String?

    internal var identifier: String

    internal lazy var item: FormTextInputItem = {
        let item = FormTextInputItem(style: style)
        item.value = value ?? ""
        item.title = localizedString(.emailItemTitle, localizationParameters)
        item.placeholder = localizedString(.emailItemPlaceHolder, localizationParameters)
        item.validator = EmailValidator()
        item.validationFailureMessage = localizedString(.emailItemInvalid, localizationParameters)
        item.keyboardType = .emailAddress
        item.identifier = identifier
        item.contentType = .emailAddress
        return item
    }()

    internal init(value: String?,
                  identifier: String,
                  style: FormTextItemStyle) {
        self.value = value
        self.identifier = identifier
        self.style = style
    }

    internal func inject(into formViewController: FormViewController) {
        formViewController.append(item)
    }

}
