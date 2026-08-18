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
    
    private enum Constants {
        static let removalConfirmationHeight: CGFloat = 164
    }

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
        .sheet(isPresented: isRemovalConfirmationPresented) {
            if let item = viewModel.itemPendingRemoval {
                if #available(iOS 16.4, *) {
                    removalConfirmationView(for: item)
                        .presentationBackground(.black.opacity(0.1))
                } else {
                    removalConfirmationView(for: item)
                }
            }
        }
        .alert(
            viewModel.removalErrorTitle,
            isPresented: isRemovalErrorPresented
        ) {
            Button(viewModel.dismissTitle) {
                viewModel.dismissRemovalError()
            }
        } message: {
            Text(viewModel.removalErrorMessage)
        }
        .accessibilityIdentifier(StoredPaymentMethodManagementAccessibilityIdentifier.screen)
    }

    private func removalConfirmationView(
        for item: StoredPaymentMethodManagementItem
    ) -> some View {
        RemovalConfirmationView(
            removalActionTitle: item.removalActionTitle,
            cancelTitle: viewModel.cancelTitle,
            theme: theme,
            onRemove: {
                Task {
                    await viewModel.confirmRemoval(of: item)
                }
            },
            onCancel: viewModel.dismissRemovalConfirmation
        )
        .presentationDetents([.height(Constants.removalConfirmationHeight)])
        .presentationDragIndicator(.hidden)
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

    private var isRemovalErrorPresented: Binding<Bool> {
        Binding(
            get: { viewModel.removalError != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissRemovalError()
                }
            }
        )
    }
}

private extension StoredPaymentMethodManagementView {
    
    private struct RemovalConfirmationView: View {
        
        private enum Constants {
            static let horizontalPadding: CGFloat = 16
            static let verticalPadding: CGFloat = 16
            static let buttonHeight: CGFloat = 52
            static let buttonSpacing: CGFloat = 8
            static let buttonCornerRadius: CGFloat = 14
        }

        fileprivate let removalActionTitle: String
        fileprivate let cancelTitle: String
        fileprivate let theme: CheckoutTheme
        fileprivate let onRemove: () -> Void
        fileprivate let onCancel: () -> Void

        var body: some View {
            VStack(spacing: Constants.buttonSpacing) {
                Button(removalActionTitle, action: onRemove)
                    .font(Font(theme.elements.labels.bodyEmphasized.font))
                    .foregroundStyle(Color(uiColor: theme.colors.textOnDestructive))
                    .frame(maxWidth: .infinity, minHeight: Constants.buttonHeight)
                    .background(Color(uiColor: theme.colors.destructive))
                    .clipShape(RoundedRectangle(cornerRadius: Constants.buttonCornerRadius))
                    .accessibilityIdentifier(StoredPaymentMethodManagementAccessibilityIdentifier.confirmRemoval)
                
                Button(cancelTitle, action: onCancel)
                    .font(Font(theme.elements.labels.bodyEmphasized.font))
                    .foregroundStyle(Color(uiColor: theme.colors.highlight))
                    .frame(maxWidth: .infinity, minHeight: Constants.buttonHeight)
                    .background(Color(uiColor: theme.colors.background))
                    .clipShape(RoundedRectangle(cornerRadius: Constants.buttonCornerRadius))
                    .accessibilityIdentifier(StoredPaymentMethodManagementAccessibilityIdentifier.cancelRemoval)
            }
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.vertical, Constants.verticalPadding)
            
        }
    }
}

// swiftlint:disable:next type_name
internal enum StoredPaymentMethodManagementAccessibilityIdentifier {
    internal static let screen = "storedPaymentMethodManagement.screen"
    internal static let paymentOptions = "storedPaymentMethodManagement.paymentOptions"
    internal static let confirmRemoval = "storedPaymentMethodManagement.confirmRemoval"
    internal static let cancelRemoval = "storedPaymentMethodManagement.cancelRemoval"

    internal static func section(_ kind: StoredPaymentMethodManagementSection.Kind) -> String {
        "storedPaymentMethodManagement.section.\(kind)"
    }

    internal static func remove(_ identifier: String) -> String {
        "storedPaymentMethodManagement.remove.\(identifier)"
    }
}
