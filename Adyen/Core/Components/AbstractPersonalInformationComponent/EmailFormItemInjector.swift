//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

final class EmailFormItemInjector: FormItemInjector, Localizable {

    /// :nodoc:
    var localizationParameters: LocalizationParameters?

    /// :nodoc:
    let style: FormTextItemStyle

    /// :nodoc:
    var value: String?

    /// :nodoc:
    var identifier: String

    /// :nodoc:
    lazy var item: FormTextInputItem = {
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

    init(value: String?,
         identifier: String,
         style: FormTextItemStyle) {
        self.value = value
        self.identifier = identifier
        self.style = style
    }

    /// :nodoc:
    func inject(into formViewController: FormViewController) {
        formViewController.append(item)
    }

}
