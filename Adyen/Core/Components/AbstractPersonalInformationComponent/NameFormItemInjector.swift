//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

final class NameFormItemInjector: FormItemInjector, Localizable {

    let contentType: UITextContentType

    /// :nodoc:
    var localizationParameters: LocalizationParameters?

    /// :nodoc:
    let style: FormTextItemStyle

    /// :nodoc:
    var value: String?

    /// :nodoc:
    var identifier: String

    /// :nodoc:
    var localizationKey: LocalizationKey

    /// :nodoc:
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

    /// :nodoc:
    func inject(into formViewController: FormViewController) {
        formViewController.append(item)
    }
    
}
