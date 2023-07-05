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
        ) { [weak delegate] searchTerm, resultHandler in
            // TODO: Provide extra cell at the end to switch to manual input or provide navigation item
            
            let handler: ([ListItem]) -> Void = { items in
                if items.isEmpty {
                    return resultHandler(items)
                }
                
                // TODO: Alex - Discuss decision with Design Team
                
                var itemsWithManualButton = items
                var listItemStyle = ListItemStyle()
                listItemStyle.title.font = .preferredFont(forTextStyle: .subheadline)
                listItemStyle.title.color = .Adyen.componentSecondaryLabel
                listItemStyle.title.textAlignment = .center
                listItemStyle.subtitle.font = .preferredFont(forTextStyle: .subheadline)
                listItemStyle.subtitle.color = .Adyen.defaultBlue
                listItemStyle.subtitle.textAlignment = .center
                
                itemsWithManualButton.append(
                    .init(
                        title: "Select your address or use",
                        subtitle: "manual address entry",
                        style: listItemStyle
                    ) { [weak delegate] in
                        delegate?.addressLookupSearchSwitchToManualEntry()
                    }
                )
                resultHandler(itemsWithManualButton)
            }
            
            delegate?.addressLookupSearchLookUp(searchTerm: searchTerm, resultHandler: handler)
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
    }
    
    @objc
    private func cancelSearch() {
        delegate?.addressLookupSearchCancel()
    }
}
