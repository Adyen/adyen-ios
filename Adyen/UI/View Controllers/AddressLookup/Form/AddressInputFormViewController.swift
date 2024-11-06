//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A ``FormViewController`` with a ``FormAddressItem`` and optional ``FormSearchButtonItem``
@_spi(AdyenInternal)
public class AddressInputFormViewController: FormViewController {
    
    private let viewModel: ViewModel
    
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
        
        super.init(
            style: viewModel.style,
            localizationParameters: viewModel.localizationParameters
        )
        
        title = viewModel.title
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        
        if viewModel.shouldShowSearch {
            append(searchButtonItem)
        }
        
        append(addressItem)
        
        setupNavigationItems()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // The done button should only be enabled once at least one field is filled in.
        // Either by prefilling or manually entering.
        // The country field is excluded as it is always prefilled.
        var itemWithoutCountry = addressItem.value
        itemWithoutCountry.country = nil
        navigationItem.rightBarButtonItem?.isEnabled = !itemWithoutCountry.isEmpty
        observe(addressItem.publisher, eventHandler: { [weak self] _ in
            self?.navigationItem.rightBarButtonItem?.isEnabled = true
        })
    }
    
    internal lazy var searchButtonItem: FormSearchButtonItem = {
        let identifier = ViewIdentifierBuilder.build(
            scopeInstance: Self.self,
            postfix: "searchBar"
        )
        
        return FormSearchButtonItem(
            placeholder: localizedString(.addressLookupSearchPlaceholder, localizationParameters),
            style: viewModel.style,
            identifier: identifier
        ) { [weak self] in
            guard let self else { return }
            self.viewModel.handleShowSearch(currentInput: self.addressItem.value)
        }
    }()
    
    internal lazy var addressItem: FormAddressItem = {
        let identifier = ViewIdentifierBuilder.build(
            scopeInstance: Self.self,
            postfix: "address"
        )
        
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

extension AddressInputFormViewController {
    
    @objc
    internal func submitTapped() {
        guard validate() else { return }
        viewModel.handleSubmit(validAddress: addressItem.value)
    }
    
    @objc
    internal func dismissAddressLookup() {
        viewModel.handleDismiss()
    }
}

private extension AddressInputFormViewController {
    
    func setupNavigationItems() {
        
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
    }
}
