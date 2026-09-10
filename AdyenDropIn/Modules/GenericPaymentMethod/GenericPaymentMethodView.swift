//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenUI
import SwiftUI

internal struct GenericPaymentMethodView: View {

    private enum Constants {
        static let logoFrame = CGSize(width: 80, height: 52)
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
            AsyncImage(url: viewModel.paymentMethodLogoURL) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: theme.attributes.cornerRadius))
            } placeholder: {
                ProgressView()
            }
            .frame(width: Constants.logoFrame.width, height: Constants.logoFrame.height)

            descriptionView

            progressView
                .padding(.top, Constants.progressViewBottomPadding)
        }
        .padding()
        .background(Color(uiColor: theme.colors.background))
    }

    // MARK: - Private

    private var descriptionView: some View {
        VStack(spacing: Constants.descriptionViewSpacing) {
            Text("\(viewModel.paymentMethodName)")
                .font(Font(theme.elements.labels.title.font))
            Text("You will be guided to the next step of the process.")
                .font(Font(theme.elements.labels.body.font))
        }
        .foregroundStyle(Color(uiColor: theme.colors.text))
        .multilineTextAlignment(.center)
        .padding(.top, Constants.descriptionViewTopPadding)

    }

    private var progressView: some View {
        VStack(spacing: Constants.progressViewSpacing) {
            CircularProgressView(theme: theme)
            Text("Processing...")
                .font(Font(theme.elements.labels.body.font))
                .foregroundStyle(Color(uiColor: theme.colors.textSecondary))
        }
    }

    internal struct CircularProgressView: View {

        private enum Constants {
            static let size: CGFloat = 48
            static let lineWidth: CGFloat = 4
            static let arcLength = 0.25
            static let rotationDuration = 0.8
        }

        internal let theme: CheckoutTheme
        @State private var isRotating = false

        internal var body: some View {
            ZStack {
                Circle()
                    .stroke(Color(uiColor: theme.colors.textOnDisabled).opacity(0.15), lineWidth: Constants.lineWidth)

                Circle()
                    .trim(from: 0, to: Constants.arcLength)
                    .stroke(
                        Color(uiColor: theme.colors.text),
                        style: StrokeStyle(lineWidth: Constants.lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(isRotating ? 360 : 0))
            }
            .frame(width: Constants.size, height: Constants.size)
            .accessibilityHidden(true)
            .onAppear {
                withAnimation(.linear(duration: Constants.rotationDuration).repeatForever(autoreverses: false)) {
                    isRotating = true
                }
            }
        }
    }
}
