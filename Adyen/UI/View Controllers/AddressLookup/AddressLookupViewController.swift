//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

// TODO: TESTS

@_spi(AdyenInternal)
public class AddressLookupViewController: UINavigationController, AdyenObserver {
    
    internal private(set) var viewModel: ViewModel
    
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        updateInterface(for: viewModel.interfaceState)
        observe(viewModel.$interfaceState) { [weak self] interfaceState in
            self?.updateInterface(for: interfaceState)
        }
        
        viewModel.handleViewDidLoad()
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var searchController: SearchViewController {
        
        let emptyView = AddressLookupSearchEmptyView(
            localizationParameters: viewModel.localizationParameters
        ) { [weak self] in
            guard let self else { return }
            self.viewModel.handleSwitchToManualEntryTapped()
        }
        
        let viewModel = SearchViewController.ViewModel(
            localizationParameters: viewModel.localizationParameters,
            style: viewModel.style,
            searchBarPlaceholder: "Search your address", // TODO: Alex - Localization
            shouldFocusSearchBarOnAppearance: true
        ) { [weak self] searchTerm, resultHandler in
            self?.viewModel.lookUp(searchTerm: searchTerm, resultHandler: resultHandler)
        }
        
        let searchController = SearchViewController(
            viewModel: viewModel,
            emptyView: emptyView
        )
        
        if #available(iOS 13.0, *) {
            searchController.isModalInPresentation = true
        }
        
        searchController.title = localizedString(.billingAddressSectionTitle, viewModel.localizationParameters)
        searchController.navigationItem.rightBarButtonItem = .init(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(dismissSearch)
        )
        
        return searchController
    }
    
    private var securedViewController: SecuredViewController {
        
        let securedViewController = SecuredViewController(
            child: formViewController,
            style: viewModel.style
        )
        securedViewController.navigationItem.leftBarButtonItem = .init(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(dismissAddressLookup)
        )
        securedViewController.navigationItem.rightBarButtonItem = .init(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
        if #available(iOS 13.0, *) {
            securedViewController.isModalInPresentation = true
        }
        return securedViewController
    }
    
    internal lazy var formViewController: AddressLookupFormViewController = {
        AddressLookupFormViewController(
            formStyle: viewModel.style,
            localizationParameters: viewModel.localizationParameters,
            initialCountry: viewModel.initialCountry,
            prefillAddress: viewModel.prefillAddress,
            supportedCountryCodes: viewModel.supportedCountryCodes
        ) { [weak self] in
            guard let self else { return }
            self.viewModel.handleShowSearchTapped(currentInput: self.formViewController.address)
        }
    }()
    
    @objc
    private func doneTapped() {
        guard let validAddress = formViewController.validateAddress() else { return }
        viewModel.handleSubmit(address: validAddress)
    }
    
    @objc
    private func dismissSearch() {
        viewModel.handleDismissSearchTapped()
    }
    
    @objc
    private func dismissAddressLookup() {
        viewModel.handleDismissAddressLookupTapped()
    }
}

// MARK: - Navigation

private extension AddressLookupViewController {
    
    func updateInterface(for interfaceState: AddressLookupViewController.ViewModel.InterfaceState) {
        switch interfaceState {
        case let .form(prefillAddress):
            prefillAddress.map { formViewController.billingAddressItem.value = $0 }
            show(viewController: securedViewController)
        case .search:
            show(viewController: searchController)
        }
    }
    
    func show(viewController: UIViewController) {
        UIView.transition(
            with: self.view,
            duration: 0.2,
            options: .transitionCrossDissolve
        ) {
            self.viewControllers = [viewController]
        }
    }
}
