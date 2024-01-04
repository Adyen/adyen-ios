//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal final class AddressFormItemInjector: FormItemInjector, Localizable {
    
    internal var localizationParameters: LocalizationParameters?

    internal var value: PostalAddress?

    private let initialCountry: String

    internal var identifier: String

    internal let style: AddressStyle

    internal let addressViewModelBuilder: AddressViewModelBuilder
    
    private weak var presenter: ViewControllerPresenter?
    
    private let addressType: FormAddressPickerItem.AddressType // TODO: Move it somewhere reusable

    internal lazy var item: FormAddressPickerItem = {
        FormAddressPickerItem(
            for: addressType,
            initialCountry: initialCountry,
            supportedCountryCodes: nil, // TODO: Pass correct values
            prefillAddress: value,
            style: style,
            addressViewModelBuilder: addressViewModelBuilder,
            presenter: self,
            lookupProvider: nil
        )
    }()
    
    internal init(
        value: PostalAddress?,
        initialCountry: String,
        identifier: String,
        style: AddressStyle,
        presenter: ViewControllerPresenter?,
        addressViewModelBuilder: AddressViewModelBuilder,
        addressType: FormAddressPickerItem.AddressType
    ) {
        self.value = value
        self.initialCountry = initialCountry
        self.identifier = identifier
        self.style = style
        self.presenter = presenter
        self.addressViewModelBuilder = addressViewModelBuilder
        self.addressType = addressType
    }

    internal func inject(into formViewController: FormViewController) {
        formViewController.append(item)
    }
    
}

extension AddressFormItemInjector: ViewControllerPresenter {
    
    func presentViewController(_ viewController: UIViewController, animated: Bool) {
        presenter?.presentViewController(viewController, animated: animated)
    }
    
    func dismissViewController(animated: Bool) {
        presenter?.dismissViewController(animated: animated)
    }
}
