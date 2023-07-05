//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

// TODO: Alex - Telemetry

/// A `FormViewController` with a `FormSearchButtonItem` and `FormAddressItem`
/// to be used via the `AddressLookupViewController`
internal class AddressLookupFormViewController: FormViewController {
    
    private let supportedCountryCodes: [String]?
    private let prefillAddress: PostalAddress?
    private let initialCountry: String
    private let formStyle: FormComponentStyle
    private let addressViewModelBuilder: AddressViewModelBuilder
    private let showSearchHandler: () -> Void
    
    internal init(
        formStyle: FormComponentStyle,
        localizationParameters: LocalizationParameters?,
        initialCountry: String,
        prefillAddress: PostalAddress?,
        supportedCountryCodes: [String]?,
        addressViewModelBuilder: AddressViewModelBuilder = DefaultAddressViewModelBuilder(),
        handleShowSearch: @escaping () -> Void
    ) {
        self.formStyle = formStyle
        self.initialCountry = initialCountry
        self.prefillAddress = prefillAddress
        self.supportedCountryCodes = supportedCountryCodes
        self.showSearchHandler = handleShowSearch
        self.addressViewModelBuilder = addressViewModelBuilder
        
        super.init(style: formStyle)
        
        self.localizationParameters = localizationParameters
        title = localizedString(.billingAddressSectionTitle, localizationParameters)
        
        append(searchButtonItem)
        append(billingAddressItem)
    }
    
    func validateAddress() -> PostalAddress? {
        validate() ? address : nil
    }
    
    var address: PostalAddress {
        get {
            billingAddressItem.value
        }
        set {
            billingAddressItem.value = newValue
        }
    }
    
    internal lazy var searchButtonItem: FormSearchButtonItem = {
        FormSearchButtonItem(
            placeholder: "Search your address", // TODO: Alex - Localization
            style: formStyle
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
            addressViewModelBuilder: addressViewModelBuilder
        )
        prefillAddress.map { item.value = $0 }
        item.style.backgroundColor = UIColor.Adyen.lightGray
        item.title = nil
        return item
    }()
}
