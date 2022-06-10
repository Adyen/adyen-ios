//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal final class PhoneFormItemInjector: FormItemInjector, Localizable {

    internal var localizationParameters: LocalizationParameters?

    internal let style: FormTextItemStyle

    internal let phoneExtensions: [PhoneExtensionPickerItem]

    internal var value: String?

    internal var identifier: String

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

    internal func inject(into formViewController: FormViewController) {
        formViewController.append(item)
    }

}
