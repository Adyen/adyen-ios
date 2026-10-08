//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import SwiftUI
import UIKit

#if canImport(AdyenUI)
    import AdyenUI
#endif

internal final class PreselectedPaymentMethodViewController: UIHostingController<PreselectedPaymentMethodView> {

    private enum Constants {
        static let sheetCornerRadius: CGFloat = 16
        static let sheetHeight: CGFloat = 500
    }

    internal let viewModel: PreselectedPaymentMethodViewModel

    internal init(viewModel: PreselectedPaymentMethodViewModel) {
        self.viewModel = viewModel
        super.init(rootView: PreselectedPaymentMethodView(viewModel: viewModel))
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override internal func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        configurePresentationSheet()
        viewModel.viewDidLoad()
    }

    /// Configures a fixed-height sheet that cannot be dismissed by swiping down.
    private func configurePresentationSheet() {
        isModalInPresentation = true

        if let sheet = sheetPresentationController {
            sheet.detents = [
                .custom { _ in
                    Constants.sheetHeight
                }
            ]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = Constants.sheetCornerRadius
        }
    }

    private func setupNavigationItem() {
        let cancelButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.leftBarButtonItem = cancelButton
    }

    @objc private func cancelTapped() {
        viewModel.cancel()
    }
}

internal struct PreselectedPaymentMethodView: View {

    private enum Constants {
        static let paymentLogoSize = CGSize(width: 80, height: 52)

        static let contentTopPadding: CGFloat = 24
        static let contentPadding: CGFloat = 24

        static let labelsToButtonPadding: CGFloat = 16

        static let logoToLabelsSpacing: CGFloat = 24

        static let labelsSpacing: CGFloat = 8

        static let buttonsSpacing: CGFloat = 16
        static let buttonsBottomPadding: CGFloat = 16
        static let buttonHeight: CGFloat = 52
    }

    @ObservedObject internal var viewModel: PreselectedPaymentMethodViewModel

    internal var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    topContent
                        .frame(maxHeight: .infinity)
                        .padding(.bottom, Constants.labelsToButtonPadding)
                    buttons
                }
                .frame(minHeight: geometry.size.height - Constants.contentTopPadding - Constants.buttonsBottomPadding)
                .padding(.top, Constants.contentTopPadding)
                .padding(.horizontal, Constants.contentPadding)
                .padding(.bottom, Constants.buttonsBottomPadding)
            }
        }
        .background(Color(uiColor: viewModel.theme.colors.background))
    }

    private var topContent: some View {
        VStack(spacing: Constants.logoToLabelsSpacing) {
            PaymentLogoView(
                url: viewModel.paymentMethodLogoURL,
                theme: viewModel.theme,
                size: Constants.paymentLogoSize
            )
            .accessibilityIdentifier(ViewIdentifierBuilder.build(scopeInstance: self, postfix: "cardShapedImage"))
            .accessibilityHidden(true)

            VStack(spacing: Constants.labelsSpacing) {
                Text(viewModel.titleText)
                    .font(Font(viewModel.theme.elements.labels.title.font))
                    .accessibilityIdentifier(ViewIdentifierBuilder.build(scopeInstance: self, postfix: "title"))
                Text(viewModel.subtitleText)
                    .font(Font(viewModel.theme.elements.labels.body.font))
                    .accessibilityIdentifier(ViewIdentifierBuilder.build(scopeInstance: self, postfix: "subTitle"))
            }
            .foregroundStyle(Color(uiColor: viewModel.theme.colors.text))
            .multilineTextAlignment(.center)
        }
    }

    private var buttons: some View {
        VStack(spacing: Constants.buttonsSpacing) {
            FormButtonRepresentable(
                title: viewModel.submitButtonTitle,
                style: viewModel.theme.elements.buttons.primary,
                isEnabled: !viewModel.isLoading,
                showsActivityIndicator: viewModel.isLoading,
                accessibilityIdentifier: ViewIdentifierBuilder.build(scopeInstance: self, postfix: "primaryButton"),
                action: viewModel.submitPayment
            )
            .frame(height: Constants.buttonHeight)

            if viewModel.showsAllPaymentMethodsButton {
                FormButtonRepresentable(
                    title: viewModel.showAllPaymentMethodsButtonTitle,
                    style: viewModel.theme.elements.buttons.secondary,
                    isEnabled: !viewModel.isLoading,
                    showsActivityIndicator: false,
                    accessibilityIdentifier: ViewIdentifierBuilder.build(scopeInstance: self, postfix: "secondaryButton"),
                    action: viewModel.showAllPaymentMethods
                )
                .frame(height: Constants.buttonHeight)
            }
        }
    }
}
