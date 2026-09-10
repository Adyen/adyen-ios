//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenUI
import SwiftUI

internal struct GenericPaymentMethodView: View {

    private enum Constants {
        static let logoSize = CGSize(width: 80, height: 52)
        static let descriptionViewSpacing: CGFloat = 16
        static let descriptionViewTopPadding: CGFloat = 32

        static let progressViewSpacing: CGFloat = 16
        static let progressViewBottomPadding: CGFloat = 64
    }

    // MARK: - Properties

    @ObservedObject internal var viewModel: GenericPaymentMethodViewModel
    internal let theme: CheckoutTheme

    // MARK: - Body

    internal var body: some View {
        VStack {
            logoView
            descriptionView
            progressView
                .padding(.top, Constants.progressViewBottomPadding)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }
                .disabled(viewModel.state == .loading)
            }
        }
        .padding()
        .background(Color(uiColor: theme.colors.background))
        .disabled(viewModel.state == .loading)
        .accessibilityIdentifier(GenericPaymentMethodAccessibilityIdentifier.screen)
        .navigationBarBackButtonHidden(true)
        .task {
            viewModel.startPayment()
        }
    }

    // MARK: - Private

    private var logoView: some View {
        PaymentLogoView(
            url: viewModel.paymentMethodLogoURL,
            theme: theme,
            size: Constants.logoSize
        )
        .accessibilityIdentifier(GenericPaymentMethodAccessibilityIdentifier.logo)
    }

    private var descriptionView: some View {
        VStack(spacing: Constants.descriptionViewSpacing) {
            Text("\(viewModel.title)")
                .font(Font(theme.elements.labels.title.font))
                .accessibilityIdentifier(GenericPaymentMethodAccessibilityIdentifier.title)
            Text(viewModel.description)
                .font(Font(theme.elements.labels.body.font))
                .accessibilityIdentifier(GenericPaymentMethodAccessibilityIdentifier.description)
        }
        .foregroundStyle(Color(uiColor: theme.colors.text))
        .multilineTextAlignment(.center)
        .padding(.top, Constants.descriptionViewTopPadding)

    }

    private var progressView: some View {
        VStack(spacing: Constants.progressViewSpacing) {
            CircularProgressView(theme: theme, size: 48, lineWidth: 4)
            Text(viewModel.progressTitle)
                .font(Font(theme.elements.labels.body.font))
                .foregroundStyle(Color(uiColor: theme.colors.textSecondary))
                .accessibilityIdentifier(GenericPaymentMethodAccessibilityIdentifier.progressTitle)
        }
    }
}

// swiftlint:disable:next type_name
internal enum GenericPaymentMethodAccessibilityIdentifier {
    internal static let screen = "genericPaymentMethod.screen"
    internal static let logo = "genericPaymentMethod.logo"
    internal static let title = "genericPaymentMethod.title"
    internal static let description = "genericPaymentMethod.description"
    internal static let progressTitle = "genericPaymentMethod.progressTitle"
}
