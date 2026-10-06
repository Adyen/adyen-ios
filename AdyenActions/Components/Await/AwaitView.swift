//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenUI
import SwiftUI

internal struct AwaitView: View {

    private enum Constants {
        static let logoSize = CGSize(width: 80, height: 52)
        static let descriptionViewSpacing: CGFloat = 8
        static let descriptionViewTopPadding: CGFloat = 24

        static let progressViewSpacing: CGFloat = 16
        static let progressViewTopPadding: CGFloat = 32
        static let progressViewSize: CGFloat = 48
        static let progressViewWidth: CGFloat = 4
    }

    // MARK: - Properties

    internal let viewModel: AwaitComponentViewModel
    internal let theme: CheckoutTheme

    // MARK: - Body

    internal var body: some View {
        VStack {
            logoView
            descriptionView
            progressView
                .padding(.top, Constants.progressViewTopPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color(uiColor: theme.colors.background))
        .accessibilityIdentifier(AwaitAccessibilityIdentifier.screen)
    }

    // MARK: - Private

    private var logoView: some View {
        PaymentLogo(
            url: viewModel.logoURL,
            theme: theme,
            size: Constants.logoSize
        )
        .accessibilityIdentifier(AwaitAccessibilityIdentifier.logo)
    }

    private var descriptionView: some View {
        VStack(spacing: Constants.descriptionViewSpacing) {
            Text(viewModel.title)
                .adyenLabelStyle(theme.elements.labels.title)
                .accessibilityIdentifier(AwaitAccessibilityIdentifier.title)
            Text(viewModel.description)
                .adyenLabelStyle(theme.elements.labels.body, color: theme.colors.textSecondary)
                .accessibilityIdentifier(AwaitAccessibilityIdentifier.description)
        }
        .foregroundStyle(Color(uiColor: theme.colors.text))
        .multilineTextAlignment(.center)
        .padding(.top, Constants.descriptionViewTopPadding)
    }

    private var progressView: some View {
        VStack(spacing: Constants.progressViewSpacing) {
            CircularProgressView(
                theme: theme,
                size: Constants.progressViewSize,
                lineWidth: Constants.progressViewWidth
            )
            Text(viewModel.progressTitle)
                .adyenLabelStyle(theme.elements.labels.body, color: theme.colors.textSecondary)
                .accessibilityIdentifier(AwaitAccessibilityIdentifier.progressTitle)
        }
    }
}

internal enum AwaitAccessibilityIdentifier {
    internal static let screen = "await.screen"
    internal static let logo = "await.logo"
    internal static let title = "await.title"
    internal static let description = "await.description"
    internal static let progressTitle = "await.progressTitle"
}
