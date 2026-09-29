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
        static let spacing: CGFloat = 16
        static let labelsSpacing: CGFloat = 8
    }

    internal let logoURL: URL
    internal let title: String
    internal let subtitle: NSAttributedString
    internal let theme: CheckoutTheme

    internal var body: some View {
        VStack(spacing: Constants.spacing) {
            PaymentLogoView(url: logoURL, theme: theme, size: Constants.logoSize)
                .accessibilityIdentifier(StoredPaymentMethodContentAccessibilityIdentifier.logo)
                .accessibilityHidden(true)

            VStack(spacing: Constants.labelsSpacing) {
                Text(title)
                    .font(Font(theme.elements.labels.title.font))
                    .accessibilityIdentifier(StoredPaymentMethodContentAccessibilityIdentifier.title)
                Text(AttributedString(subtitle))
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
            subtitle: NSAttributedString(string: "Use Visa to pay €10.00"),
            theme: theme
        )
        .padding()
        .background(Color(uiColor: theme.colors.background))
    }
#endif
