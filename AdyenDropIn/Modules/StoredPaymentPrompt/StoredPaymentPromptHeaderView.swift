//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenUI)
    import AdyenUI
#endif
import SwiftUI

internal struct StoredPaymentPromptHeaderView: View {

    internal let logoURL: URL
    internal let title: String
    internal let subtitle: NSAttributedString
    internal let theme: CheckoutTheme
    internal let logoSize: CGSize
    internal let spacing: CGFloat
    internal let labelsSpacing: CGFloat
    internal let accessibilityIDs: AccessibilityIDs

    internal struct AccessibilityIDs {
        internal let logo: String
        internal let title: String
        internal let subtitle: String
    }

    internal var body: some View {
        VStack(spacing: spacing) {
            PaymentLogoView(url: logoURL, theme: theme, size: logoSize)
                .accessibilityIdentifier(accessibilityIDs.logo)
                .accessibilityHidden(true)

            VStack(spacing: labelsSpacing) {
                Text(title)
                    .font(Font(theme.elements.labels.title.font))
                    .accessibilityIdentifier(accessibilityIDs.title)
                Text(AttributedString(subtitle))
                    .accessibilityIdentifier(accessibilityIDs.subtitle)
            }
            .foregroundStyle(Color(uiColor: theme.colors.text))
            .multilineTextAlignment(.center)
            .accessibilityElement(children: .contain)
        }
    }
}
