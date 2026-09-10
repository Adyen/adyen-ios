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

            } placeholder: {
                ProgressView()
            }
            .frame(width: Constants.logoFrame.width, height: Constants.logoFrame.height)

            VStack(spacing: 16) {
                Text("\(viewModel.paymentMethodName)")
                    .font(Font(theme.elements.labels.title.font))
                Text("You will be guided to the next step of the process.")
                    .font(Font(theme.elements.labels.body.font))
            }
            .foregroundStyle(Color(uiColor: theme.colors.text))
            .multilineTextAlignment(.center)
            .padding(.top, 32)

            ProgressView {
                Text("Processing")
            }
            .task {
                viewModel.startPayment()

            }
            .padding(.top, 64)
        }
        .padding()
        .background(Color(uiColor: theme.colors.background))
    }

    // MARK: - Private
}
