//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A ``FormViewController`` with a (optional)``FormSearchButtonItem`` and ``FormAddressItem``
///
/// To be used via the ``AddressInputViewController``
@_spi(AdyenInternal)
public class AddressInputFormViewController: FormViewController {
    
    private let viewModel: ViewModel
    
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
        
        super.init(
            style: viewModel.style,
            localizationParameters: viewModel.localizationParameters
        )
        
        title = localizedString(.billingAddressSectionTitle, viewModel.localizationParameters)
        
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
        
        if viewModel.shouldShowSearch {
            append(searchButtonItem)
        }
        
        append(billingAddressItem)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // The done button should only be enabled once at least one field is filled in.
        // Either by prefilling or manually entering.
        // The country field is excluded as it is always prefilled.
        var itemWithoutCountry = billingAddressItem.value
        itemWithoutCountry.country = nil
        navigationItem.rightBarButtonItem?.isEnabled = !itemWithoutCountry.isEmpty
        observe(billingAddressItem.publisher, eventHandler: { [weak self] _ in
            self?.navigationItem.rightBarButtonItem?.isEnabled = true
        })
    }
    
    internal lazy var searchButtonItem: FormSearchButtonItem = {
        FormSearchButtonItem(
            placeholder: localizedString(.addressLookupSearchPlaceholder, localizationParameters),
            style: viewModel.style
        ) { [weak self] in
            guard let self else { return }
            self.viewModel.handleShowSearch(currentInput: self.billingAddressItem.value)
        }
    }()
    
    internal lazy var billingAddressItem: FormAddressItem = {
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "billingAddress")
        let item = FormAddressItem(
            initialCountry: viewModel.initialCountry,
            configuration: .init(
                style: viewModel.style.addressStyle,
                localizationParameters: viewModel.localizationParameters,
                supportedCountryCodes: viewModel.supportedCountryCodes,
                showsHeader: false
            ),
            identifier: identifier,
            presenter: self,
            addressViewModelBuilder: viewModel.addressViewModelBuilder
        )
        viewModel.prefillAddress.map { item.value = $0 }
        item.style.backgroundColor = UIColor.Adyen.lightGray
        item.title = nil
        return item
    }()
}

private extension AddressInputFormViewController {
    
    @objc
    func submitTapped() {
        guard validate() else { return }
        viewModel.handleSubmit(validAddress: billingAddressItem.value)
    }
    
    @objc
    func dismissAddressLookup() {
        viewModel.handleDismiss()
    }
}
