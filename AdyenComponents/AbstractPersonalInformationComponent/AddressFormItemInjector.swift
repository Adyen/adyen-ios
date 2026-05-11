//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
    @_spi(AdyenInternal) import class AdyenUI.FormViewController
#endif
import UIKit

internal final class AddressFormItemInjector: FormItemInjector, Localizable {
    
    internal var localizationParameters: LocalizationParameters?

    internal var value: PostalAddress?

    private let initialCountry: String

    internal var identifier: String

    internal let style: FormComponentStyle

    internal let addressViewModelBuilder: AddressViewModelBuilder
    
    private weak var presenter: ViewControllerPresenter?
    
    private let addressType: FormAddressPickerItem.AddressType

    internal lazy var item: FormAddressPickerItem = {
        .init(
            for: addressType,
            initialCountry: initialCountry,
            supportedCountryCodes: nil,
            prefillAddress: value,
            style: style,
            localizationParameters: localizationParameters,
            identifier: identifier,
            addressViewModelBuilder: addressViewModelBuilder,
            presenter: self,
            lookupProvider: nil
        )
    }()
    
    internal init(
        value: PostalAddress?,
        initialCountry: String,
        identifier: String,
        style: FormComponentStyle,
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
        let sectionTitle = addressType.sectionTitle(with: localizationParameters)
        formViewController.append(item.withSectionHeader(
            title: sectionTitle,
            subtitle: nil // TODO: Add subtitle localization key
        ))
    }
    
}

extension AddressFormItemInjector: ViewControllerPresenter {
    
    internal func presentViewController(_ viewController: UIViewController, animated: Bool) {
        presenter?.presentViewController(viewController, animated: animated)
    }
    
    internal func dismissViewController(animated: Bool) {
        presenter?.dismissViewController(animated: animated)
    }
}
