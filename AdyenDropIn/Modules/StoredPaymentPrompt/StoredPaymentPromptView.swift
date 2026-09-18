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
        static let labelsSpacing: CGFloat = 8
        static let backButtonSpacing: CGFloat = 5
        static let buttonHeight: CGFloat = 52
        static let buttonCornerRadius: CGFloat = 14
        static let buttonContentSpacing: CGFloat = 10
        static let buttonImageSize: CGFloat = 24

        /// The component owns the content below the header, which sits at the top of the screen.
        enum Input {
            static let contentSpacing: CGFloat = 24
            static let headerSpacing: CGFloat = 16
        }

        /// Drop-in owns the confirmation button, so the header is centered above it.
        enum Confirmation {
            static let contentSpacing: CGFloat = 16
            static let headerSpacing: CGFloat = 24
        }
    }

    @ObservedObject private var viewModel: StoredPaymentPromptViewModel

    internal init(viewModel: StoredPaymentPromptViewModel) {
        self.viewModel = viewModel
    }

    internal var body: some View {
        content
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
            inputContent(componentViewController: componentViewController)
        } else {
            confirmationContent
        }
    }

    private func inputContent(componentViewController: UIViewController) -> some View {
        VStack(spacing: Constants.Input.contentSpacing) {
            header(spacing: Constants.Input.headerSpacing)
                .padding(.horizontal, Constants.contentPadding)

            ComponentViewControllerView(viewController: componentViewController)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.top, Constants.Input.contentSpacing)
    }

    private var confirmationContent: some View {
        VStack(spacing: Constants.Confirmation.contentSpacing) {
            header(spacing: Constants.Confirmation.headerSpacing)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if let submitButtonTitle = viewModel.submitButtonTitle {
                submitButton(title: submitButtonTitle)
            }
        }
        .padding(.horizontal, Constants.contentPadding)
        .padding(.bottom, Constants.contentPadding)
    }

    private func header(spacing: CGFloat) -> some View {
        StoredPaymentPromptHeaderView(
            logoURL: viewModel.paymentMethodLogoURL,
            title: viewModel.title,
            subtitle: viewModel.subtitle,
            theme: viewModel.theme,
            logoSize: Constants.logoSize,
            spacing: spacing,
            labelsSpacing: Constants.labelsSpacing,
            accessibilityIDs: .init(
                logo: StoredPaymentPromptAccessibilityID.logo,
                title: StoredPaymentPromptAccessibilityID.title,
                subtitle: StoredPaymentPromptAccessibilityID.subtitle
            )
        )
    }

    private func submitButton(title: String) -> some View {
        Button {
            viewModel.submit()
        } label: {
            HStack(spacing: Constants.buttonContentSpacing) {
                if viewModel.isSubmitting {
                    ProgressView()
                        .tint(Color(uiColor: viewModel.theme.elements.buttons.primary.textColor))
                } else if viewModel.showsLockIcon,
                          let image = UIImage.adyenLock ?? UIImage.systemLock {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Constants.buttonImageSize, height: Constants.buttonImageSize)
                        .accessibilityHidden(true)
                }
                Text(title)
                    .font(Font(viewModel.theme.elements.labels.bodyEmphasized.font))
            }
            .frame(maxWidth: .infinity, minHeight: Constants.buttonHeight)
        }
        .buttonStyle(
            StoredPaymentPromptButtonStyle(
                style: viewModel.theme.elements.buttons.primary,
                cornerRadius: Constants.buttonCornerRadius
            )
        )
        .disabled(viewModel.isSubmitting)
        .accessibilityIdentifier(StoredPaymentPromptAccessibilityID.submitButton)
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
        .disabled(viewModel.isSubmitting)
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

private struct StoredPaymentPromptButtonStyle: SwiftUI.ButtonStyle {

    let style: AdyenButtonStyle
    let cornerRadius: CGFloat

    func makeBody(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        configuration.label
            .foregroundStyle(Color(uiColor: style.textColor))
            .background(Color(uiColor: style.backgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

internal enum StoredPaymentPromptAccessibilityID {
    internal static let screen = "storedPaymentPrompt.screen"
    internal static let logo = "storedPaymentPrompt.logo"
    internal static let title = "storedPaymentPrompt.title"
    internal static let subtitle = "storedPaymentPrompt.subtitle"
    internal static let submitButton = "storedPaymentPrompt.submitButton"
}
