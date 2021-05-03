//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal final class NameFormItemInjector: FormItemInjector, Localizable {

    /// :nodoc:
    internal var localizationParameters: LocalizationParameters?

    /// :nodoc:
    internal let style: FormTextItemStyle

    /// :nodoc:
    internal var identifier: String

    /// :nodoc:
    internal var localizationKey: LocalizationKey

    /// :nodoc:
    internal lazy var item: FormTextInputItem = {
        let item = FormTextInputItem(style: style)
        item.title = localizedString(localizationKey, localizationParameters)
        item.placeholder = localizedString(localizationKey, localizationParameters)
        item.validator = LengthValidator(minimumLength: 1, maximumLength: 50)
        item.validationFailureMessage = nil
        item.autocapitalizationType = .words
        item.identifier = identifier
        return item
    }()

    internal init(identifier: String, localizationKey: LocalizationKey, style: FormTextItemStyle) {
        self.identifier = identifier
        self.localizationKey = localizationKey
        self.style = style
    }

    /// :nodoc:
    internal func inject(into formViewController: FormViewController) {
        formViewController.append(item)
    }
    
}
