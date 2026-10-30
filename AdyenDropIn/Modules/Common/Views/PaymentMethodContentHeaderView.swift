//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

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

    internal let viewModel: PaymentMethodContentHeaderViewModel
    internal let accessibilityIdentifiers: PaymentMethodContentHeaderView.AccessibilityIdentifiers

    internal var body: some View {
        VStack(spacing: Constants.spacing) {
            PaymentMethodLogoView(url: viewModel.logoURL, theme: viewModel.theme, size: Constants.logoSize)
                .accessibilityIdentifier(accessibilityIdentifiers.logo)
                .accessibilityHidden(true)

            VStack(spacing: Constants.labelsSpacing) {
                Text(viewModel.title)
                    .adyenLabelStyle(viewModel.theme.elements.labels.title)
                    .accessibilityIdentifier(accessibilityIdentifiers.title)
                Text(viewModel.subtitle)
                    .adyenLabelStyle(viewModel.theme.elements.labels.body)
                    .accessibilityIdentifier(accessibilityIdentifiers.subtitle)
            }
            .multilineTextAlignment(.center)
        }
    }
}
