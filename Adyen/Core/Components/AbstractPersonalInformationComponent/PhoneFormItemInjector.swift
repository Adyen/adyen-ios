//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal final class PhoneFormItemInjector: FormItemInjector, Localizable {

    /// :nodoc:
    internal var localizationParameters: LocalizationParameters?

    /// :nodoc:
    internal let style: FormTextItemStyle

    /// :nodoc:
    internal let phoneExtensions: [PhoneExtensionPickerItem]

    /// :nodoc:
    internal var value: String?

    /// :nodoc:
    internal var identifier: String

    /// :nodoc:
    internal lazy var item: FormPhoneNumberItem = {
        let item = FormPhoneNumberItem(selectableValues: phoneExtensions,
                                       style: style,
                                       localizationParameters: localizationParameters)
        item.value = value ?? ""
        item.identifier = identifier
        return item
    }()

    internal init(value: String?,
                  identifier: String,
                  phoneExtensions: [PhoneExtensionPickerItem],
                  style: FormTextItemStyle) {
        self.value = value
        self.identifier = identifier
        self.phoneExtensions = phoneExtensions
        self.style = style
    }

    /// :nodoc:
    internal func inject(into formViewController: FormViewController) {
        formViewController.append(item)
    }

}
