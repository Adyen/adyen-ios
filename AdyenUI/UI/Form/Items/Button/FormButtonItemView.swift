//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A view representing a button item.
internal final class FormButtonItemView: FormItemView<FormButtonItem> {

    /// The theme for styling.
    package let theme: AdyenTheme

    /// Initializes the footer item view.
    ///
    /// - Parameters:
    ///   - item: The item represented by the view.
    ///   - theme: The theme to use for styling.
    internal init(item: FormButtonItem, theme: AdyenTheme) {
        self.theme = theme
        super.init(item: item)

        addSubview(submitButton)

        preservesSuperviewLayoutMargins = true

        bind(item.$showsActivityIndicator, to: submitButton, at: \.showsActivityIndicator)
        bind(item.$enabled, to: submitButton, at: \.isEnabled)
        bind(item.$title, to: submitButton, at: \.title)

        submitButton.adyen.anchor(inside: self.layoutMarginsGuide)
    }

    /// Initializes the footer item view with default theme.
    ///
    /// - Parameter item: The item represented by the view.
    internal required convenience init(item: FormButtonItem) {
        self.init(item: item, theme: .default)
    }

    // MARK: - Submit Button

    internal lazy var submitButton: SubmitButton = {
        let submitButton = SubmitButton(theme: theme, style: item.style.button)

        submitButton.addTarget(self, action: #selector(didSelectSubmitButton), for: .touchUpInside)
        submitButton.accessibilityIdentifier = item.identifier.map {
            ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "button")
        }

        submitButton.preservesSuperviewLayoutMargins = true
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        return submitButton
    }()

    @objc internal func didSelectSubmitButton() {
        item.buttonSelectionHandler?()
    }
}
