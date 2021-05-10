//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A view representing a footer item.
internal final class FormButtonItemView: FormItemView<FormButtonItem>, Observer {
    /// Initializes the footer item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormButtonItem) {
        super.init(item: item)
        backgroundColor = item.style.backgroundColor

        addSubview(submitButton)

        bind(item.$showsActivityIndicator, to: submitButton, at: \.showsActivityIndicator)
        bind(item.$enabled, to: submitButton, at: \.isEnabled)

        configureConstraints()
    }

    // MARK: - Submit Button

    private lazy var submitButton: SubmitButton = {
        let submitButton = SubmitButton(style: item.style.button)

        submitButton.title = item.title
        submitButton.addTarget(self, action: #selector(didSelectSubmitButton), for: .touchUpInside)
        submitButton.accessibilityIdentifier = item.identifier.map {
            ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "button")
        }

        submitButton.preservesSuperviewLayoutMargins = true
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        return submitButton
    }()

    @objc private func didSelectSubmitButton() {
        item.buttonSelectionHandler?()
    }

    // MARK: - Layout

    private func configureConstraints() {
        let constraints = [
            submitButton.topAnchor.constraint(equalTo: topAnchor),
            submitButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            submitButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}
