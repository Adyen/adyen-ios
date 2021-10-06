//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

internal final class NameFormItemInjector: FormItemInjector, Localizable {

    internal let contentType: UITextContentType

    /// :nodoc:
    internal var localizationParameters: LocalizationParameters?

    /// :nodoc:
    internal let style: FormTextItemStyle

    /// :nodoc:
    internal var value: String?

    /// :nodoc:
    internal var identifier: String

    /// :nodoc:
    internal var localizationKey: LocalizationKey

    /// :nodoc:
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

    /// :nodoc:
    internal func inject(into formViewController: FormViewController) {
        formViewController.append(item)
    }
    
}
