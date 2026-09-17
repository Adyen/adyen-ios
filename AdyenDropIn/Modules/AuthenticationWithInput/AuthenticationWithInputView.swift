//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenUI)
    import AdyenUI
#endif
import SwiftUI

internal struct AuthenticationWithInputView: View {

    private enum Constants {
        static let logoSize = CGSize(width: 80, height: 52)
        static let contentPadding: CGFloat = 16
        static let contentSpacing: CGFloat = 24
        static let headerSpacing: CGFloat = 16
        static let labelsSpacing: CGFloat = 8
    }

    @ObservedObject private var viewModel: AuthenticationWithInputViewModel

    internal init(viewModel: AuthenticationWithInputViewModel) {
        self.viewModel = viewModel
    }

    internal var body: some View {
        VStack(spacing: Constants.contentSpacing) {
            AuthenticationWithInputHeaderView(
                logoURL: viewModel.paymentMethodLogoURL,
                title: viewModel.title,
                subtitle: viewModel.subtitle,
                theme: viewModel.theme,
                logoSize: Constants.logoSize,
                spacing: Constants.headerSpacing,
                labelsSpacing: Constants.labelsSpacing
            )
            .padding(.horizontal, Constants.contentPadding)

            PaymentComponentViewController(
                viewController: viewModel.componentViewController
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.top, Constants.contentSpacing)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: viewModel.theme.colors.background))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.cancel()
                } label: {
                    Label(viewModel.backButtonTitle, systemImage: "chevron.backward")
                }
            }
        }
        .tint(Color(uiColor: viewModel.theme.colors.highlight))
        .navigationBarBackButtonHidden(true)
        .accessibilityIdentifier(AuthenticationInputAccessibilityID.screen)
    }
}

private struct AuthenticationWithInputHeaderView: View {

    let logoURL: URL
    let title: String
    let subtitle: NSAttributedString
    let theme: CheckoutTheme
    let logoSize: CGSize
    let spacing: CGFloat
    let labelsSpacing: CGFloat

    var body: some View {
        VStack(spacing: spacing) {
            PaymentLogoView(url: logoURL, theme: theme, size: logoSize)
                .accessibilityIdentifier(AuthenticationInputAccessibilityID.logo)
                .accessibilityHidden(true)

            VStack(spacing: labelsSpacing) {
                Text(title)
                    .font(Font(theme.elements.labels.title.font))
                    .accessibilityIdentifier(AuthenticationInputAccessibilityID.title)
                Text(AttributedString(subtitle))
                    .accessibilityIdentifier(AuthenticationInputAccessibilityID.subtitle)
            }
            .foregroundStyle(Color(uiColor: theme.colors.text))
            .multilineTextAlignment(.center)
            .accessibilityElement(children: .contain)
        }
    }
}

private struct PaymentComponentViewController: UIViewControllerRepresentable {

    let viewController: UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

internal enum AuthenticationInputAccessibilityID {
    internal static let screen = "authenticationWithInput.screen"
    internal static let logo = "authenticationWithInput.logo"
    internal static let title = "authenticationWithInput.title"
    internal static let subtitle = "authenticationWithInput.subtitle"
}
