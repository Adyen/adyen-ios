//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A view representing a button item.
internal final class FormSearchButtonItemView: FormItemView<FormSearchButtonItem> {
    
    private let theme: CheckoutTheme

    /// Initializes the footer item view.
    ///
    /// - Parameters:
    ///   - item: The item represented by the view.
    ///   - theme: The theme to use for styling.
    internal init(item: FormSearchButtonItem, theme: CheckoutTheme) {
        self.theme = theme
        super.init(item: item)
        
        backgroundColor = theme.colors.background
        preservesSuperviewLayoutMargins = true
        
        addSubview(searchBar)
        searchBar.adyen.anchor(inside: self, with: .init(top: 0, left: 8, bottom: 0, right: 8))
        
        bind(item.$placeholder, to: searchBar, at: \.placeholder)
    }
    
    internal required convenience init(item: FormSearchButtonItem) {
        self.init(item: item, theme: .default)
    }
    
    // MARK: - Submit Button
    
    private lazy var searchBar: UISearchBar = {

        .prominent(
            placeholder: item.placeholder,
            backgroundColor: theme.colors.background,
            delegate: self
        )
    }()
    
    override internal func becomeFirstResponder() -> Bool {
        searchBar.becomeFirstResponder()
    }
}

extension FormSearchButtonItemView: UISearchBarDelegate {
    
    internal func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        item.selectionHandler()
        return false
    }
}
