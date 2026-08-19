//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenUI)
    import AdyenUI
#endif
import SwiftUI

@MainActor
internal struct StoredPaymentMethodManagementEmptyState: View {

    private enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let verticalSpacing: CGFloat = 16
    }

    @ObservedObject private var viewModel: StoredPaymentMethodManagementViewModel
    private let theme: CheckoutTheme

    internal init(viewModel: StoredPaymentMethodManagementViewModel, theme: CheckoutTheme) {
        self.viewModel = viewModel
        self.theme = theme
    }

    internal var body: some View {
        VStack(spacing: Constants.verticalSpacing) {
            Spacer()

            VStack(spacing: 4) {
                Text(viewModel.emptyTitle)
                    .font(.headline)
                    .foregroundStyle(Color(uiColor: theme.colors.text))

                Text(viewModel.emptyMessage)
                    .font(.subheadline)
                    .foregroundStyle(Color(uiColor: theme.colors.textSecondary))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Constants.horizontalPadding)

            Spacer()

            Button(viewModel.paymentOptionsTitle) {
                viewModel.didRequestPaymentOptions()
            }
            .font(.body.weight(.semibold))
            .foregroundStyle(Color(uiColor: theme.colors.textOnPrimary))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(uiColor: theme.colors.primary))
            .clipShape(RoundedRectangle(cornerRadius: theme.attributes.cornerRadius))
            .accessibilityIdentifier(StoredPaymentMethodManagementAccessibilityIdentifier.paymentOptions)
        }
        .padding(Constants.horizontalPadding)
    }
}
