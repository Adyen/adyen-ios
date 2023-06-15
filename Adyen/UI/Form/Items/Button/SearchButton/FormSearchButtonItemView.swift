//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A view representing a button item.
internal final class FormSearchButtonItemView: FormItemView<FormSearchButtonItem> {
    
    /// Initializes the footer item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormSearchButtonItem) {
        super.init(item: item)
        backgroundColor = .clear // item.style.backgroundColor
        
        addSubview(searchBar)
        addSubview(button)

        preservesSuperviewLayoutMargins = true
        
        bind(item.$placeholder, to: searchBar, at: \.placeholder)
        
        searchBar.adyen.anchor(inside: self, with: .init(top: 0, left: 8, bottom: 0, right: -8))
        button.adyen.anchor(inside: self)
    }
    
    // MARK: - Submit Button
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .prominent
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
//        searchBar.barTintColor = style.backgroundColor // TODO: Styling
        searchBar.isUserInteractionEnabled = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(didSelectSubmitButton), for: .touchUpInside)
        return button
    }()
    
    @objc private func didSelectSubmitButton() {
        item.selectionHandler()
    }
    
}
