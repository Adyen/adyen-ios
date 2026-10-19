//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif
import PassKit
import UIKit

/// A screen that contains only the Apple Pay button.
///
/// It has no background or scrolling of its own, so it can be embedded in other screens.
package final class ApplePayButtonViewController: UIViewController {

    private enum Layout {
        static let buttonHeight: CGFloat = 48
    }

    /// Called when the shopper taps the Apple Pay button.
    package var onSubmit: (() -> Void)?

    private let appearance: ApplePayButtonAppearance
    private let showsSubmitButton: Bool

    internal private(set) lazy var paymentButton: PKPaymentButton = {
        let button = PKPaymentButton(
            paymentButtonType: appearance.buttonType,
            paymentButtonStyle: appearance.buttonStyle
        )
        if let cornerRadius = appearance.cornerRadius {
            button.cornerRadius = cornerRadius
        }
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "applePayButton")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(paymentButtonTapped), for: .touchUpInside)
        return button
    }()

    /// Creates the Apple Pay button screen.
    /// - Parameters:
    ///   - appearance: The appearance of the Apple Pay button.
    ///   - showsSubmitButton: Whether the screen shows the Apple Pay button. When `false`, the screen is empty.
    package init(
        appearance: ApplePayButtonAppearance,
        showsSubmitButton: Bool
    ) {
        self.appearance = appearance
        self.showsSubmitButton = showsSubmitButton
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    package required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override package func viewDidLoad() {
        super.viewDidLoad()
        if showsSubmitButton {
            addPaymentButton()
        }
    }

    private func addPaymentButton() {
        view.addSubview(paymentButton)

        // Low priority, so the screen shrinks to the button when embedded and keeps the button
        // at the top when shown full screen.
        let bottomConstraint = paymentButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        bottomConstraint.priority = .defaultLow

        NSLayoutConstraint.activate([
            paymentButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            paymentButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            paymentButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            paymentButton.bottomAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.bottomAnchor),
            paymentButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            bottomConstraint
        ])
    }

    @objc private func paymentButtonTapped() {
        onSubmit?()
    }
}
