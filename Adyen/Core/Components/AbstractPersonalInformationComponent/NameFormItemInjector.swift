//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

internal final class NameFormItemInjector: FormItemInjector, Localizable {

    internal let contentType: UITextContentType

    internal var localizationParameters: LocalizationParameters?

    internal let style: FormTextItemStyle

    internal var value: String?

    internal var identifier: String

    internal var localizationKey: LocalizationKey

    internal lazy var item: FormTextInputItem = {
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

    internal init(value: String?,
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

    internal func inject(into formViewController: FormViewController) {
        formViewController.append(item)
    }
    
}
