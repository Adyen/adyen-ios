//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A view representing a button item.
internal final class FormSearchButtonItemView: FormItemView<FormSearchButtonItem> {
    
    /// Initializes the footer item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(
        item: FormSearchButtonItem
    ) {
        super.init(item: item)
        
        backgroundColor = item.style.backgroundColor
        preservesSuperviewLayoutMargins = true
        
        addSubview(searchBar)
        searchBar.adyen.anchor(inside: self, with: .init(top: 0, left: 8, bottom: 0, right: -8))
        
        bind(item.$placeholder, to: searchBar, at: \.placeholder)
    }
    
    // MARK: - Submit Button
    
    private lazy var searchBar: UISearchBar = {

        .prominent(
            placeholder: item.placeholder,
            backgroundColor: item.style.backgroundColor,
            delegate: self
        )
    }()
}

extension FormSearchButtonItemView: UISearchBarDelegate {
    
    internal func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        item.selectionHandler()
        return false
    }
}
