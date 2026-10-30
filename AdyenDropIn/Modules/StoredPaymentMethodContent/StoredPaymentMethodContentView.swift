//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenCard)
    import AdyenCard
#endif
#if canImport(AdyenUI)
    import AdyenUI
#endif
import SwiftUI

internal struct StoredPaymentMethodContentView: View {

    private enum Constants {
        static let contentPadding: CGFloat = 16
        static let contentSpacing: CGFloat = 32
        static let bottomPadding: CGFloat = 16
    }

    private let viewModel: StoredPaymentMethodContentViewModel

    internal init(viewModel: StoredPaymentMethodContentViewModel) {
        self.viewModel = viewModel
    }

    internal var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: Constants.contentSpacing) {
                    PaymentMethodContentHeaderView(
                        viewModel: viewModel.header,
                        accessibilityIdentifiers: .init(
                            logo: StoredPaymentMethodContentAccessibilityIdentifier.logo,
                            title: StoredPaymentMethodContentAccessibilityIdentifier.title,
                            subtitle: StoredPaymentMethodContentAccessibilityIdentifier.subtitle
                        )
                    )
                    .padding(.horizontal, Constants.contentPadding)

                    ComponentViewControllerView(viewController: viewModel.componentViewController)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, Constants.bottomPadding)
                .frame(minHeight: geometry.size.height)
            }
        }
        .background(Color(uiColor: viewModel.theme.colors.background))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
        }
        .navigationBarBackButtonHidden(true)
        .accessibilityIdentifier(StoredPaymentMethodContentAccessibilityIdentifier.screen)
    }

    private var backButton: some View {
        Button {
            viewModel.cancel()
        } label: {
            Image(systemName: "chevron.backward")
        }
    }
}

private struct ComponentViewControllerView: UIViewControllerRepresentable {

    let viewController: UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    /// A view controller has no intrinsic size, so its content is measured against the proposed
    /// width to give it a height of its own inside the scroll view.
    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiViewController: UIViewController,
        context: Context
    ) -> CGSize? {
        guard let width = proposal.width, width > 0 else { return nil }

        let fittingSize = uiViewController.view.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        return CGSize(width: width, height: fittingSize.height)
    }
}

// swiftlint:disable:next type_name
internal enum StoredPaymentMethodContentAccessibilityIdentifier {
    internal static let screen = "storedPaymentMethodContent.screen"
    internal static let logo = "storedPaymentMethodContent.logo"
    internal static let title = "storedPaymentMethodContent.title"
    internal static let subtitle = "storedPaymentMethodContent.subtitle"
}
