//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

@_spi(AdyenInternal)
public extension UISearchBar {
    
    static func prominent(
        placeholder: String?,
        backgroundColor: UIColor,
        delegate: UISearchBarDelegate
    ) -> UISearchBar {
        
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .prominent
        searchBar.placeholder = placeholder
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = backgroundColor
        searchBar.delegate = delegate
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }
}
