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
        static let topPadding: CGFloat = 24
        static let messageSpacing: CGFloat = 8
        static let buttonHeight: CGFloat = 52
    }

    @ObservedObject private var viewModel: StoredPaymentMethodManagementViewModel
    private let theme: CheckoutTheme

    internal init(viewModel: StoredPaymentMethodManagementViewModel, theme: CheckoutTheme) {
        self.viewModel = viewModel
        self.theme = theme
    }

    internal var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: Constants.messageSpacing) {
                Text(viewModel.emptyTitle)
                    .adyenLabelStyle(theme.elements.labels.title2)

                Text(viewModel.emptyMessage)
                    .adyenLabelStyle(theme.elements.labels.body)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()

            Button(viewModel.paymentOptionsTitle, action: viewModel.didRequestPaymentOptions)
                .font(Font(theme.elements.labels.bodyEmphasized.font))
                .foregroundStyle(Color(uiColor: theme.colors.textOnPrimary))
                .frame(maxWidth: .infinity, minHeight: Constants.buttonHeight)
                .background(Color(uiColor: theme.colors.primary))
                .clipShape(RoundedRectangle(cornerRadius: theme.attributes.cornerRadius))
                .accessibilityIdentifier(StoredPaymentMethodManagementAccessibilityIdentifier.paymentOptions)
        }
        .padding(.top, Constants.topPadding)
    }
}
