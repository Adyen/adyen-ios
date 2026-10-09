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

internal struct StoredPaymentMethodContentHeaderView: View {

    private enum Constants {
        static let logoSize = CGSize(width: 80, height: 52)
        static let spacing: CGFloat = 24
        static let labelsSpacing: CGFloat = 8
    }

    internal let logoURL: URL
    internal let title: String
    internal let subtitle: String
    internal let theme: CheckoutTheme

    internal var body: some View {
        VStack(spacing: Constants.spacing) {
            PaymentMethodLogoView(url: logoURL, theme: theme, size: Constants.logoSize)
                .accessibilityIdentifier(StoredPaymentMethodContentAccessibilityIdentifier.logo)
                .accessibilityHidden(true)

            VStack(spacing: Constants.labelsSpacing) {
                Text(title)
                    .adyenLabelStyle(theme.elements.labels.title)
                    .accessibilityIdentifier(StoredPaymentMethodContentAccessibilityIdentifier.title)
                Text(subtitle)
                    .adyenLabelStyle(theme.elements.labels.body, color: theme.colors.textSecondary)
                    .accessibilityIdentifier(StoredPaymentMethodContentAccessibilityIdentifier.subtitle)
            }
            .foregroundStyle(Color(uiColor: theme.colors.text))
            .multilineTextAlignment(.center)
        }
    }
}

#if DEBUG
    #Preview("Stored payment method header") {
        let theme = CheckoutTheme.default
        StoredPaymentMethodContentHeaderView(
            logoURL: LogoURLProvider(environment: Environment.test).logoURL(withName: "visa"),
            title: "•••• 1111",
            subtitle: "Use Visa to pay €10.00",
            theme: theme
        )
        .padding()
        .background(Color(uiColor: theme.colors.background))
    }
#endif
