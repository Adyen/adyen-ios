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
        static let contentPadding: CGFloat = 16
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
                content
            } else {
                ScrollView {
                    content
                }
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
        .accessibilityIdentifier(StoredPaymentMethodManagementAccessibilityIdentifier.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            HeaderView(
                title: viewModel.title,
                description: viewModel.description,
                theme: theme
            )

            if viewModel.isEmpty {
                StoredPaymentMethodManagementEmptyState(viewModel: viewModel, theme: theme)
            } else {
                StoredPaymentMethodManagementListView(viewModel: viewModel, theme: theme)
            }
        }
        .padding(Constants.contentPadding)
        .frame(maxWidth: .infinity, alignment: .topLeading)
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

}

private extension StoredPaymentMethodManagementView {

    private struct HeaderView: View {

        private enum Constants {
            static let spacing: CGFloat = 8
        }

        let title: String
        let description: String
        let theme: CheckoutTheme

        var body: some View {
            VStack(alignment: .leading, spacing: Constants.spacing) {
                Text(title)
                    .font(Font(theme.elements.labels.title.font))
                    .foregroundStyle(Color(uiColor: theme.elements.labels.title.color))

                Text(description)
                    .font(Font(theme.elements.labels.body.font))
                    .foregroundStyle(Color(uiColor: theme.elements.labels.body.color))
            }
        }
    }
    
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
