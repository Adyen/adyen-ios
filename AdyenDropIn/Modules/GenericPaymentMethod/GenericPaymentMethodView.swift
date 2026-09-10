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
        .padding()
        .background(Color(uiColor: theme.colors.background))
        .disabled(viewModel.state == .loading)
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
    }

    private var descriptionView: some View {
        VStack(spacing: Constants.descriptionViewSpacing) {
            Text("\(viewModel.title)")
                .font(Font(theme.elements.labels.title.font))
            Text(viewModel.description)
                .font(Font(theme.elements.labels.body.font))
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
        }
    }
}
