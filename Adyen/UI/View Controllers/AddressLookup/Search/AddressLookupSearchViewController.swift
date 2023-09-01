//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// The delegate protocol of the ``AddressLookupViewController``
protocol AddressLookupSearchDelegate: AnyObject {
    
    /// Switch to manual address entry was requested
    func addressLookupSearchSwitchToManualEntry()
    /// Provide list items for addresses matching the searchTerm
    func addressLookupSearchLookUp(searchTerm: String, resultHandler: @escaping ([ListItem]) -> Void)
    /// Cancelling the search was requested
    func addressLookupSearchCancel()
}

/// The search view controller to be used for address lookup
///
/// See: ``AddressLookupViewController``
class AddressLookupSearchViewController: SearchViewController {
    
    private weak var delegate: AddressLookupSearchDelegate?
    
    /// Initializes the address lookup search
    ///
    /// - Parameters:
    ///   - style: The style of the view.
    ///   - localizationParameters: The localization parameters
    ///   - delegate: The delegate conforming to ``AddressLookupSearchDelegate``
    init(
        style: AddressLookupSearchStyle = .init(),
        localizationParameters: LocalizationParameters?,
        delegate: AddressLookupSearchDelegate
    ) {
        let emptyView = EmptyView(
            localizationParameters: localizationParameters
        ) { [weak delegate] in
            delegate?.addressLookupSearchSwitchToManualEntry()
        }
        
        let viewModel = SearchViewController.ViewModel(
            localizationParameters: localizationParameters,
            style: style,
            searchBarPlaceholder: localizedString(.addressLookupSearchPlaceholder, localizationParameters),
            shouldFocusSearchBarOnAppearance: true
        ) { [weak delegate] searchTerm, resultHandler in
            delegate?.addressLookupSearchLookUp(searchTerm: searchTerm) {
                guard let delegate else { return }
                resultHandler(Self.listItems(
                    from: $0,
                    with: delegate,
                    style: style.manualEntryListItem,
                    localizationParameters: localizationParameters
                ))
            }
        }
        
        self.delegate = delegate
        
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
        delegate?.addressLookupSearchCancel()
    }
    
    private static func listItems(
        from results: [ListItem],
        with delegate: AddressLookupSearchDelegate,
        style: ListItemStyle,
        localizationParameters: LocalizationParameters?
    ) -> [ListItem] {
        
        if results.isEmpty {
            return results
        }
        
        let manualEntryListItem = ListItem(
            title: localizedString(.addressLookupSearchManualEntryItemTitle, localizationParameters),
            style: style
        ) {
            delegate.addressLookupSearchSwitchToManualEntry()
        }
        
        return [manualEntryListItem] + results
    }
}
