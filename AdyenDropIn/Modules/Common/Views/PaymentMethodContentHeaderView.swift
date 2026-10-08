//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if DEBUG
    import Adyen
#endif
#if canImport(AdyenUI)
    import AdyenUI
#endif
import SwiftUI

internal struct PaymentMethodContentHeaderView: View {

    private enum Constants {
        static let logoSize = CGSize(width: 80, height: 52)
        static let spacing: CGFloat = 24
        static let labelsSpacing: CGFloat = 8
    }

    internal struct AccessibilityIdentifiers {
        internal let logo: String
        internal let title: String
        internal let subtitle: String
    }

    internal let logoURL: URL
    internal let title: String
    internal let subtitle: AttributedString
    internal let theme: CheckoutTheme
    internal let accessibilityIdentifiers: PaymentMethodContentHeaderView.AccessibilityIdentifiers

    internal var body: some View {
        VStack(spacing: Constants.spacing) {
            PaymentLogoView(url: logoURL, theme: theme, size: Constants.logoSize)
                .accessibilityIdentifier(accessibilityIdentifiers.logo)
                .accessibilityHidden(true)

            VStack(spacing: Constants.labelsSpacing) {
                Text(title)
                    .font(Font(theme.elements.labels.title.font))
                    .accessibilityIdentifier(accessibilityIdentifiers.title)
                Text(subtitle)
                    .accessibilityIdentifier(accessibilityIdentifiers.subtitle)
            }
            .foregroundStyle(Color(uiColor: theme.colors.text))
            .multilineTextAlignment(.center)
        }
    }
}

#if DEBUG
    #Preview("Payment method content header") {
        let theme = CheckoutTheme.default
        PaymentMethodContentHeaderView(
            logoURL: LogoURLProvider(environment: Environment.test).logoURL(withName: "visa"),
            title: "•••• 1111",
            subtitle: AttributedString("Use Visa to pay €10.00"),
            theme: theme,
            accessibilityIdentifiers: .init(
                logo: "preview.logo",
                title: "preview.title",
                subtitle: "preview.subtitle"
            )
        )
        .padding()
        .background(Color(uiColor: theme.colors.background))
    }
#endif
