//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

// TODO: Documentation

internal protocol AddressLookupSearchViewControllerDelegate: AnyObject {
    
    func addressLookupSearchSwitchToManualEntry()
    func addressLookupSearchLookUp(searchTerm: String, resultHandler: @escaping ([ListItem]) -> Void)
    func addressLookupSearchCancel()
}

internal class AddressLookupSearchViewController: SearchViewController {
    
    private weak var delegate: AddressLookupSearchViewControllerDelegate?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let footerView = FooterView { [weak self] in
            self?.switchToManualEntry()
        }
        
        resultsListViewController.tableView.update(tableFooterView: footerView)
    }
    
    override internal func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        resultsListViewController.tableView.update(tableFooterView: resultsListViewController.tableView.tableFooterView)
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

extension UITableView {
    
    func update(tableFooterView: UIView?) {
        
        self.tableFooterView = nil
        
        guard let tableFooterView else { return }
        
//        tableFooterView.subviews.forEach {
//            $0.setNeedsLayout()
//            $0.layoutIfNeeded()
//        }
//
//        tableFooterView.setNeedsLayout()
//        tableFooterView.layoutIfNeeded()
//
//        let preferredSize = tableFooterView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
//        let preferredHeight2 = tableFooterView.systemLayoutSizeFitting(bounds.size)
//
        let newSize = tableFooterView.systemLayoutSizeFitting(.init(width: bounds.width, height: 0))
        tableFooterView.frame.size.height = newSize.height
        self.tableFooterView = tableFooterView
    }
}
