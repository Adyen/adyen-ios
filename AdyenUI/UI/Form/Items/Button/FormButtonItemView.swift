//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A view representing a button item.
internal final class FormButtonItemView: FormItemView<FormButtonItem> {

    /// The theme for styling.
    package let theme: AdyenTheme

    /// Initializes the button item view.
    ///
    /// - Parameters:
    ///   - item: The item represented by the view.
    ///   - theme: The theme to use for styling.
    internal init(item: FormButtonItem, theme: AdyenTheme) {
        self.theme = theme
        super.init(item: item)

        addSubview(button)

        preservesSuperviewLayoutMargins = true

        bind(item.$showsActivityIndicator, to: button, at: \.showsActivityIndicator)
        bind(item.$enabled, to: button, at: \.isEnabled)
        bind(item.$title, to: button, at: \.title)

        button.adyen.anchor(inside: self.layoutMarginsGuide)
    }

    /// Initializes the button item view with default theme.
    ///
    /// - Parameter item: The item represented by the view.
    internal required convenience init(item: FormButtonItem) {
        self.init(item: item, theme: .default)
    }

    // MARK: - Button

    internal lazy var button: FormButton = {
        let button = FormButton(theme: theme, style: item.style.button)

        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.accessibilityIdentifier = item.identifier.map {
            ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "button")
        }

        button.preservesSuperviewLayoutMargins = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    @objc internal func didTapButton() {
        item.buttonSelectionHandler?()
    }
}
