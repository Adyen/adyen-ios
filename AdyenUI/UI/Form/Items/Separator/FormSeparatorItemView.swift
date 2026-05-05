//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A view representing a separator line item.
internal final class FormSeparatorItemView: FormItemView<FormSeparatorItem> {

    /// Theme for styling (accessible to subclasses if needed).
    private let theme: CheckoutTheme

    /// Initializes the separator line item view with theme.
    ///
    /// - Parameters:
    ///   - item: The item represented by the view.
    ///   - theme: The theme to use for styling.
    internal init(item: FormSeparatorItem, theme: CheckoutTheme) {
        self.theme = theme
        super.init(item: item)

        addSubview(separator)

        configureConstraints()
    }

    /// Satisfies parent's required initializer. Delegates to main initializer with default theme.
    internal required convenience init(item: FormSeparatorItem) {
        self.init(item: item, theme: .default)
    }

    // MARK: - Separator

    private lazy var separator: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = theme.colors.separator
        view.accessibilityIdentifier = item.identifier.map {
            ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "separatorLine")
        }
        return view
    }()
    
    // MARK: - Layout
    
    private func configureConstraints() {
        separator.adyen.anchor(inside: self)
        separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
    }
    
}
