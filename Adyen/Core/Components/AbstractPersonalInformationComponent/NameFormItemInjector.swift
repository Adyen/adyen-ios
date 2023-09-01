//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

final class NameFormItemInjector: FormItemInjector, Localizable {

    let contentType: UITextContentType

    var localizationParameters: LocalizationParameters?

    let style: FormTextItemStyle

    var value: String?

    var identifier: String

    var localizationKey: LocalizationKey

    lazy var item: FormTextInputItem = {
        let item = FormTextInputItem(style: style)
        item.value = value ?? ""
        item.title = localizedString(localizationKey, localizationParameters)
        item.placeholder = localizedString(localizationKey, localizationParameters)
        item.validator = LengthValidator(minimumLength: 1, maximumLength: 50)
        item.validationFailureMessage = nil
        item.autocapitalizationType = .words
        item.identifier = identifier
        item.contentType = contentType
        return item
    }()

    init(value: String?,
         identifier: String,
         localizationKey: LocalizationKey,
         style: FormTextItemStyle,
         contentType: UITextContentType = .name) {
        self.value = value
        self.identifier = identifier
        self.localizationKey = localizationKey
        self.style = style
        self.contentType = contentType
    }

    func inject(into formViewController: FormViewController) {
        formViewController.append(item)
    }
    
}
