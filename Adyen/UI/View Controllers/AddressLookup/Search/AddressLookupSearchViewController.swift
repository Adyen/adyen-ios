//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// The search view controller to be used for address lookup
///
/// See: ``AddressLookupViewController``
internal class AddressLookupSearchViewController: SearchViewController {
    
    private let lookupSearchViewModel: ViewModel

    /// Initializes the address lookup search
    ///
    
    internal init(
        viewModel lookupSearchViewModel: ViewModel
    ) {
        self.lookupSearchViewModel = lookupSearchViewModel
        
        let emptyView = EmptyView(
            localizationParameters: lookupSearchViewModel.localizationParameters
        ) {
            lookupSearchViewModel.handleSwitchToManualEntry()
        }
        
        let viewModel = SearchViewController.ViewModel(
            localizationParameters: lookupSearchViewModel.localizationParameters,
            style: lookupSearchViewModel.style,
            searchBarPlaceholder: localizedString(.addressLookupSearchPlaceholder, lookupSearchViewModel.localizationParameters),
            shouldFocusSearchBarOnAppearance: true
        ) { searchTerm, resultHandler in
            lookupSearchViewModel.handleLookUp(searchTerm: searchTerm, resultHandler: resultHandler)
        }
        
        super.init(
            viewModel: viewModel,
            emptyView: emptyView
        )
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        
        title = localizedString(.billingAddressSectionTitle, viewModel.localizationParameters)
        
        navigationItem.leftBarButtonItem = .init(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelSearch)
        )
        
        navigationItem.rightBarButtonItem = .init(
            barButtonSystemItem: .done,
            target: nil,
            action: nil
        )
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        searchBar.textContentType = .fullStreetAddress
    }
    
    @objc
    private func cancelSearch() {
        lookupSearchViewModel.handleCancel()
    }
}
