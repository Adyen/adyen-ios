//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

final class AddressFormItemInjector: FormItemInjector, Localizable {
    
    /// :nodoc:
    var localizationParameters: LocalizationParameters?

    /// :nodoc:
    var value: PostalAddress?

    /// :nodoc:
    private let initialCountry: String

    /// :nodoc:
    var identifier: String

    /// :nodoc:
    let style: AddressStyle

    /// :nodoc:
    lazy var item: FormAddressItem = {
        let addressItem = FormAddressItem(initialCountry: initialCountry,
                                          style: style,
                                          localizationParameters: localizationParameters,
                                          identifier: identifier)
        value.map { addressItem.value = $0 }
        return addressItem
    }()
    
    init(value: PostalAddress?,
         initialCountry: String,
         identifier: String,
         style: AddressStyle) {
        self.value = value
        self.initialCountry = initialCountry
        self.identifier = identifier
        self.style = style
    }

    /// :nodoc:
    func inject(into formViewController: FormViewController) {
        formViewController.append(item)
    }
    
}
