//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

package extension UISearchBar {
    
    private enum Constants {
        static let fieldCornerRadius: CGFloat = 14
        static let focusedBorderWidth: CGFloat = 2
        static let backgroundImageSize = CGSize(width: 32, height: 36)
    }
    
    static func prominent(
        placeholder: String?,
        theme: CheckoutTheme,
        delegate: UISearchBarDelegate
    ) -> UISearchBar {
        let searchBar = UISearchBar()
        // `.minimal` has no bar background or top/bottom borders; the view's
        // background color shows through instead.
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = delegate
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.adyenApplyFieldStyle(theme: theme, isEditing: false)
        return searchBar
    }
    
    /// Applies the design system styling to the search field.
    ///
    /// Called by `prominent(placeholder:theme:delegate:)` and again by the
    /// `UISearchBarDelegate` on `searchBarTextDidBeginEditing` / `searchBarTextDidEndEditing`,
    /// since the only public way to show the focused border is swapping the field's
    /// background image.
    func adyenApplyFieldStyle(theme: CheckoutTheme, isEditing: Bool) {
        setSearchFieldBackgroundImage(
            Self.searchFieldBackground(theme: theme, isEditing: isEditing),
            for: .normal
        )
        if let searchIcon = UIImage.adyenSearch {
            setImage(
                searchIcon.withTintColor(theme.colors.text, renderingMode: .alwaysOriginal),
                for: .search,
                state: .normal
            )
        }
        if let clearIcon = UIImage.adyenCross {
            setImage(
                clearIcon.withTintColor(theme.colors.text, renderingMode: .alwaysOriginal),
                for: .clear,
                state: .normal
            )
        }
        
        let textField = searchTextField
        textField.clearButtonMode = .always
        textField.font = theme.elements.labels.body.font
        textField.textColor = theme.colors.text
        textField.tintColor = theme.colors.primary
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [.foregroundColor: theme.colors.textSecondary]
        )
    }
    
    private static func searchFieldBackground(theme: CheckoutTheme, isEditing: Bool) -> UIImage {
        let size = Constants.backgroundImageSize
        let image = UIGraphicsImageRenderer(size: size).image { context in
            let borderWidth = isEditing ? Constants.focusedBorderWidth : 0
            let rect = CGRect(origin: .zero, size: size).insetBy(dx: borderWidth, dy: borderWidth)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: Constants.fieldCornerRadius - borderWidth)
            theme.colors.container.setFill()
            path.fill()
            if borderWidth > 0 {
                theme.colors.primary.setStroke()
                path.lineWidth = borderWidth
                path.stroke()
            }
            context.cgContext.addPath(path.cgPath)
        }
        let capInset = Constants.fieldCornerRadius
        return image.resizableImage(withCapInsets: UIEdgeInsets(
            top: capInset, left: capInset, bottom: capInset, right: capInset
        ))
    }
}
