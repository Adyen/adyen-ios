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
            AuthenticationHeaderView(
                logoURL: viewModel.paymentMethodLogoURL,
                title: viewModel.title,
                subtitle: viewModel.subtitle,
                theme: viewModel.theme,
                logoSize: Constants.logoSize,
                spacing: Constants.headerSpacing,
                labelsSpacing: Constants.labelsSpacing,
                accessibilityIDs: .init(
                    logo: AuthenticationInputAccessibilityID.logo,
                    title: AuthenticationInputAccessibilityID.title,
                    subtitle: AuthenticationInputAccessibilityID.subtitle
                )
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
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.backward")
                        Text(viewModel.backButtonTitle)
                    }
                }
            }
        }
        .tint(Color(uiColor: viewModel.theme.colors.highlight))
        .navigationBarBackButtonHidden(true)
        .accessibilityIdentifier(AuthenticationInputAccessibilityID.screen)
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
