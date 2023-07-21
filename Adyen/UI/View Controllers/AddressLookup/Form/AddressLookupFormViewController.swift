//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// The delegate protocol of the ``AddressLookupFormViewController``
internal protocol AddressLookupFormViewControllerDelegate: AnyObject {
    
    /// Address search was requested
    func addressLookupFormShowSearch(currentInput: PostalAddress)
    /// A valid address is requested to be submitted
    func addressLookupFormSubmit(validAddress: PostalAddress)
    /// Dismissal of address lookup is requested
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
        
        super.init(
            style: formStyle,
            localizationParameters: localizationParameters
        )
        
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
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        
        // The done button should only be enabled once at least one field is filled in.
        // Either by prefilling or manually entering.
        // The country field is excluded as it is always prefilled.
        var itemWithoutCountry = billingAddressItem.value
        itemWithoutCountry.country = nil
        self.navigationItem.rightBarButtonItem?.isEnabled = !itemWithoutCountry.isEmpty
        observe(billingAddressItem.publisher, eventHandler: { [weak self] _ in
            self?.navigationItem.rightBarButtonItem?.isEnabled = true
        })
    }
    
    internal lazy var searchButtonItem: FormSearchButtonItem = {
        FormSearchButtonItem(
            placeholder: localizedString(.addressLookupSearchPlaceholder, localizationParameters),
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
            presenter: self,
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
    func submitTapped() {
        guard validate() else { return }
        lookupDelegate?.addressLookupFormSubmit(validAddress: billingAddressItem.value)
    }
    
    @objc
    func dismissAddressLookup() {
        lookupDelegate?.addressLookupFormDismiss()
    }
}
