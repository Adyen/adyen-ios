//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenUI)
    import AdyenUI
#endif
import SwiftUI

internal struct StoredPaymentPromptView: View {

    private enum Constants {
        static let logoSize = CGSize(width: 80, height: 52)
        static let contentPadding: CGFloat = 16
        static let contentSpacing: CGFloat = 24
        static let headerSpacing: CGFloat = 16
        static let labelsSpacing: CGFloat = 8
        static let backButtonSpacing: CGFloat = 5
    }

    @ObservedObject private var viewModel: StoredPaymentPromptViewModel

    internal init(viewModel: StoredPaymentPromptViewModel) {
        self.viewModel = viewModel
    }

    internal var body: some View {
        VStack(spacing: Constants.contentSpacing) {
            StoredPaymentPromptHeaderView(
                logoURL: viewModel.paymentMethodLogoURL,
                title: viewModel.title,
                subtitle: viewModel.subtitle,
                theme: viewModel.theme,
                logoSize: Constants.logoSize,
                spacing: Constants.headerSpacing,
                labelsSpacing: Constants.labelsSpacing,
                accessibilityIDs: .init(
                    logo: StoredPaymentPromptAccessibilityID.logo,
                    title: StoredPaymentPromptAccessibilityID.title,
                    subtitle: StoredPaymentPromptAccessibilityID.subtitle
                )
            )
            .padding(.horizontal, Constants.contentPadding)

            content
        }
        .padding(.top, Constants.contentSpacing)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: viewModel.theme.colors.background))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
        }
        .tint(Color(uiColor: viewModel.theme.colors.highlight))
        .navigationBarBackButtonHidden(true)
        .accessibilityIdentifier(StoredPaymentPromptAccessibilityID.screen)
        .onAppear { viewModel.didAppear() }
        .onDisappear { viewModel.didDisappear() }
    }

    @ViewBuilder
    private var content: some View {
        if let componentViewController = viewModel.componentViewController {
            ComponentViewControllerView(viewController: componentViewController)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var backButton: some View {
        Button {
            viewModel.cancel()
        } label: {
            HStack(spacing: Constants.backButtonSpacing) {
                Image(systemName: "chevron.backward")
                Text(viewModel.backButtonTitle)
            }
        }
    }
}

/// Embeds the view controller of a component that owns its own input.
private struct ComponentViewControllerView: UIViewControllerRepresentable {

    let viewController: UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

internal enum StoredPaymentPromptAccessibilityID {
    internal static let screen = "storedPaymentPrompt.screen"
    internal static let logo = "storedPaymentPrompt.logo"
    internal static let title = "storedPaymentPrompt.title"
    internal static let subtitle = "storedPaymentPrompt.subtitle"
}
