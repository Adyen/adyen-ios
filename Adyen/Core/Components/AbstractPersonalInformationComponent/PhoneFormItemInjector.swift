//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

final class PhoneFormItemInjector: FormItemInjector, Localizable {

    /// :nodoc:
    var localizationParameters: LocalizationParameters?

    /// :nodoc:
    let style: FormTextItemStyle

    /// :nodoc:
    let phoneExtensions: [PhoneExtensionPickerItem]

    /// :nodoc:
    var value: String?

    /// :nodoc:
    var identifier: String

    /// :nodoc:
    lazy var item: FormPhoneNumberItem = {
        let item = FormPhoneNumberItem(selectableValues: phoneExtensions,
                                       style: style,
                                       localizationParameters: localizationParameters)
        item.value = value ?? ""
        item.identifier = identifier
        return item
    }()

    init(value: String?,
         identifier: String,
         phoneExtensions: [PhoneExtensionPickerItem],
         style: FormTextItemStyle) {
        self.value = value
        self.identifier = identifier
        self.phoneExtensions = phoneExtensions
        self.style = style
    }

    /// :nodoc:
    func inject(into formViewController: FormViewController) {
        formViewController.append(item)
    }

}
