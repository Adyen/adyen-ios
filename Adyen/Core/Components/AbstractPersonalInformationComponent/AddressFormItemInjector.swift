//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

final class AddressFormItemInjector: FormItemInjector, Localizable {
    
    var localizationParameters: LocalizationParameters?

    var value: PostalAddress?

    private let initialCountry: String

    var identifier: String

    let style: AddressStyle

    let addressViewModelBuilder: AddressViewModelBuilder
    
    private weak var presenter: ViewControllerPresenter?

    lazy var item: FormAddressItem = {
        let addressItem = FormAddressItem(initialCountry: initialCountry,
                                          configuration: .init(
                                              style: style,
                                              localizationParameters: localizationParameters
                                          ),
                                          identifier: identifier,
                                          presenter: presenter,
                                          addressViewModelBuilder: addressViewModelBuilder)
        value.map { addressItem.value = $0 }
        return addressItem
    }()
    
    init(value: PostalAddress?,
         initialCountry: String,
         identifier: String,
         style: AddressStyle,
         presenter: ViewControllerPresenter?,
         addressViewModelBuilder: AddressViewModelBuilder) {
        self.value = value
        self.initialCountry = initialCountry
        self.identifier = identifier
        self.style = style
        self.presenter = presenter
        self.addressViewModelBuilder = addressViewModelBuilder
    }

    func inject(into formViewController: FormViewController) {
        formViewController.append(item)
    }
    
}
