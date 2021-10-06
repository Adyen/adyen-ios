//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal final class AddressFormItemInjector: FormItemInjector, Localizable {
    
    /// :nodoc:
    internal var localizationParameters: LocalizationParameters?

    /// :nodoc:
    internal var value: PostalAddress?

    /// :nodoc:
    private let initialCountry: String

    /// :nodoc:
    internal var identifier: String

    /// :nodoc:
    internal let style: AddressStyle

    /// :nodoc:
    internal lazy var item: FormAddressItem = {
        let addressItem = FormAddressItem(initialCountry: initialCountry,
                                          style: style,
                                          localizationParameters: localizationParameters,
                                          identifier: identifier)
        value.map { addressItem.value = $0 }
        return addressItem
    }()
    
    internal init(value: PostalAddress?,
                  initialCountry: String,
                  identifier: String,
                  style: AddressStyle) {
        self.value = value
        self.initialCountry = initialCountry
        self.identifier = identifier
        self.style = style
    }

    /// :nodoc:
    internal func inject(into formViewController: FormViewController) {
        formViewController.append(item)
    }
    
}
