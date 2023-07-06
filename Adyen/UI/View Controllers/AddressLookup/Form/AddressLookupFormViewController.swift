//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

// TODO: Alex - Telemetry
// TODO: Alex - Documentation

protocol AddressLookupFormViewControllerDelegate: AnyObject {
    
    func addressLookupFormShowSearch(currentInput: PostalAddress)
    func addressLookupFormSubmit(validAddress: PostalAddress)
    func addressLookupFormDismiss()
}

/// A ``FormViewController`` with a ``FormSearchButtonItem`` and ``FormAddressItem``
///
/// To be used via the ``AddressLookupViewController``
internal class AddressLookupFormViewController: FormViewController {
    
    private let supportedCountryCodes: [String]?
    private let prefillAddress: PostalAddress?
    private let initialCountry: String
    private let formStyle: FormComponentStyle
    private let addressViewModelBuilder: AddressViewModelBuilder
    private weak var lookupDelegate: AddressLookupFormViewControllerDelegate?
    
    internal init(
        formStyle: FormComponentStyle,
        localizationParameters: LocalizationParameters?,
        initialCountry: String,
        prefillAddress: PostalAddress?,
        supportedCountryCodes: [String]?,
        addressViewModelBuilder: AddressViewModelBuilder = DefaultAddressViewModelBuilder(),
        delegate: AddressLookupFormViewControllerDelegate
    ) {
        self.formStyle = formStyle
        self.initialCountry = initialCountry
        self.prefillAddress = prefillAddress
        self.supportedCountryCodes = supportedCountryCodes
        self.lookupDelegate = delegate
        self.addressViewModelBuilder = addressViewModelBuilder
        
        super.init(style: formStyle)
        
        self.localizationParameters = localizationParameters
        title = localizedString(.billingAddressSectionTitle, localizationParameters)
        
        navigationItem.leftBarButtonItem = .init(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(dismissAddressLookup)
        )
        navigationItem.rightBarButtonItem = .init(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(submitTapped)
        )
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        
        append(searchButtonItem)
        append(billingAddressItem)
    }
    
    internal lazy var searchButtonItem: FormSearchButtonItem = {
        FormSearchButtonItem(
            placeholder: "Search your address", // TODO: Alex - Localization
            style: formStyle
        ) { [weak self] in
            guard let self else { return }
            self.lookupDelegate?.addressLookupFormShowSearch(currentInput: self.billingAddressItem.value)
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

private extension AddressLookupFormViewController {
    
    @objc
    private func submitTapped() {
        guard validate() else { return }
        lookupDelegate?.addressLookupFormSubmit(validAddress: billingAddressItem.value)
    }
    
    @objc
    private func dismissAddressLookup() {
        lookupDelegate?.addressLookupFormDismiss()
    }
}