//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal final class PhoneFormItemInjector: FormItemInjector, Localizable {

    internal var localizationParameters: LocalizationParameters?

    internal let style: FormTextItemStyle

    internal let phoneExtensions: [PhoneExtension]

    internal var value: PhoneNumber?

    internal var identifier: String
    
    internal let presenter: WeakReferenceViewControllerPresenter

    internal lazy var item: FormPhoneNumberItem = {
        let item = FormPhoneNumberItem(
            phoneNumber: value,
            selectableValues: phoneExtensions,
            style: style,
            localizationParameters: localizationParameters,
            presenter: presenter
        )
        item.identifier = identifier
        return item
    }()

    internal init(
        value: PhoneNumber?,
        identifier: String,
        phoneExtensions: [PhoneExtension],
        style: FormTextItemStyle,
        presenter: ViewControllerPresenter
    ) {
        self.value = value
        self.identifier = identifier
        self.phoneExtensions = phoneExtensions
        self.style = style
        self.presenter = .init(presenter)
    }

    internal func inject(into formViewController: FormViewController) {
        formViewController.append(item)
    }

}
