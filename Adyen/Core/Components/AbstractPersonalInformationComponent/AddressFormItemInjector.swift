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
    internal let style: AddressStyle

    /// :nodoc:
    internal var identifier: String
    
    /// :nodoc:
    private let initialCountry: String

    /// :nodoc:
    internal lazy var item = FormAddressItem(initialCountry: initialCountry,
                                             style: style,
                                             localizationParameters: localizationParameters,
                                             identifier: identifier)
    
    internal init(identifier: String, initialCountry: String, style: AddressStyle) {
        self.identifier = identifier
        self.initialCountry = initialCountry
        self.style = style
    }

    /// :nodoc:
    internal func inject(into formViewController: FormViewController) {
        formViewController.append(item)
    }
    
}
