//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

internal class AddressLookupFormViewController: FormViewController {
    
    private let supportedCountryCodes: [String]?
    private let prefillAddress: PostalAddress?
    private let initialCountry: String
    private let formStyle: FormComponentStyle
    private let showSearchHandler: () -> Void
    
    internal init(
        formStyle: FormComponentStyle,
        localizationParameters: LocalizationParameters?,
        initialCountry: String,
        prefillAddress: PostalAddress?,
        supportedCountryCodes: [String]?,
        handleShowSearch: @escaping () -> Void
    ) {
        self.formStyle = formStyle
        self.initialCountry = initialCountry
        self.prefillAddress = prefillAddress
        self.supportedCountryCodes = supportedCountryCodes
        self.showSearchHandler = handleShowSearch
        
        super.init(style: formStyle)
        
        self.localizationParameters = localizationParameters
        title = "Billing Address"
//        delegate = self // TODO: Implement
        
        append(searchButtonItem)
        append(billingAddressItem) // TODO: Attach the billing address item closer to the search button
    }
    
    internal lazy var searchButtonItem: FormSearchButtonItem = {
        FormSearchButtonItem(
            placeholder: "Search your address",
            style: formStyle // TODO: Confirm that the styling actually works as expected
        ) { [weak self] in
            self?.showSearchHandler()
        }
    }()
    
    internal lazy var billingAddressItem: FormAddressItem = {
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "billingAddress")
        let item = FormAddressItem(
            initialCountry: initialCountry,
            configuration: .init(
                style: formStyle.addressStyle,
                localizationParameters: localizationParameters,
                supportedCountryCodes: supportedCountryCodes,
                showsHeader: false
            ),
            identifier: identifier,
            addressViewModelBuilder: DefaultAddressViewModelBuilder() // TODO: Make this injectable!
        )
        prefillAddress.map { item.value = $0 }
        item.style.backgroundColor = UIColor.Adyen.lightGray
        item.title = nil
        return item
    }()
}
