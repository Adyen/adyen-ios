//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// The delegate protocol of the ``AddressLookupViewController``
internal protocol AddressLookupSearchViewControllerDelegate: AnyObject {
    
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
internal class AddressLookupSearchViewController: SearchViewController {
    
    private weak var delegate: AddressLookupSearchViewControllerDelegate?
    
    /// Initializes the address lookup search
    ///
    /// - Parameters:
    ///   - style: The style of the view.
    ///   - localizationParameters: The localization parameters
    ///   - delegate: The delegate conforming to ``AddressLookupSearchViewControllerDelegate``
    internal init(
        style: ViewStyle,
        localizationParameters: LocalizationParameters?,
        delegate: AddressLookupSearchViewControllerDelegate
    ) {
        let emptyView = EmptyView(
            localizationParameters: localizationParameters
        ) { [weak delegate] in
            delegate?.addressLookupSearchSwitchToManualEntry()
        }
        
        let viewModel = SearchViewController.ViewModel(
            localizationParameters: localizationParameters,
            style: style,
            searchBarPlaceholder: "Search your address", // TODO: Alex - Localization
            shouldFocusSearchBarOnAppearance: true
        ) { [weak delegate] in
            delegate?.addressLookupSearchLookUp(searchTerm: $0, resultHandler: $1)
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
        
        navigationItem.rightBarButtonItem = .init(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelSearch)
        )
        
        searchBar.textContentType = .fullStreetAddress
    }
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Alex - Align with Design Team
        
        let footerView = FooterView { [weak self] in
            self?.switchToManualEntry()
        }

        resultsListViewController.tableView.update(tableFooterView: footerView)
    }
    
    @objc
    private func switchToManualEntry() {
        delegate?.addressLookupSearchSwitchToManualEntry()
    }
    
    @objc
    private func cancelSearch() {
        delegate?.addressLookupSearchCancel()
    }
}

// MARK: - UITableView Extension

extension UITableView {
    
    func update(tableFooterView: UIView?) {
        
        self.tableFooterView = nil
        
        guard let tableFooterView else { return }

        let newSize = tableFooterView.systemLayoutSizeFitting(.init(width: bounds.width, height: 0))
        tableFooterView.frame.size.height = newSize.height
        self.tableFooterView = tableFooterView
    }
}
