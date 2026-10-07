//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

#if canImport(AdyenUI)
    import AdyenUI
#endif

/// A navigation controller whose bar tint and titles follow the checkout theme.
/// The system bar background is kept, so that the bar still blurs the content scrolling underneath it.
@MainActor
internal final class CheckoutNavigationController: UINavigationController {

    // MARK: - Initializers

    internal init(
        rootViewController: UIViewController,
        theme: CheckoutTheme
    ) {
        super.init(rootViewController: rootViewController)
        apply(theme)
    }

    @available(*, unavailable)
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func apply(_ theme: CheckoutTheme) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.titleTextAttributes = attributes(for: theme.elements.labels.bodyEmphasized)
        appearance.largeTitleTextAttributes = attributes(for: theme.elements.labels.title)

        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.tintColor = theme.colors.primary
    }

    private func attributes(for style: AdyenLabelStyle) -> [NSAttributedString.Key: Any] {
        [
            .font: style.font,
            .foregroundColor: style.color
        ]
    }
}
