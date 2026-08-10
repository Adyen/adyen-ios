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
internal struct StoredPaymentMethodManagementView: View {

    @ObservedObject private var viewModel: StoredPaymentMethodManagementViewModel
    private let theme: CheckoutTheme

    internal init(viewModel: StoredPaymentMethodManagementViewModel, theme: CheckoutTheme) {
        self.viewModel = viewModel
        self.theme = theme
    }

    internal var body: some View {
        Group {
            if viewModel.isEmpty {
                StoredPaymentMethodManagementEmptyState(viewModel: viewModel, theme: theme)
            } else {
                StoredPaymentMethodManagementListView(viewModel: viewModel, theme: theme)
            }
        }
        .background(Color(uiColor: theme.colors.background))
        .confirmationDialog(
            "",
            isPresented: isRemovalConfirmationPresented,
            titleVisibility: .hidden,
            presenting: viewModel.itemPendingRemoval
        ) { item in
            Button(viewModel.removalActionTitle(for: item), role: .destructive) {
                Task {
                    await viewModel.confirmRemoval(of: item)
                }
            }

            Button(viewModel.cancelTitle, role: .cancel) {
                viewModel.dismissRemovalConfirmation()
            }
        }
        .accessibilityIdentifier(StoredPaymentMethodManagementAccessibilityIdentifier.screen)
    }

    private var isRemovalConfirmationPresented: Binding<Bool> {
        Binding(
            get: { viewModel.itemPendingRemoval != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissRemovalConfirmation()
                }
            }
        )
    }

}

// swiftlint:disable:next type_name
internal enum StoredPaymentMethodManagementAccessibilityIdentifier {
    internal static let screen = "storedPaymentMethodManagement.screen"
    internal static let paymentOptions = "storedPaymentMethodManagement.paymentOptions"

    internal static func section(_ kind: StoredPaymentMethodManagementSection.Kind) -> String {
        "storedPaymentMethodManagement.section.\(kind)"
    }

    internal static func remove(_ identifier: String) -> String {
        "storedPaymentMethodManagement.remove.\(identifier)"
    }
}
