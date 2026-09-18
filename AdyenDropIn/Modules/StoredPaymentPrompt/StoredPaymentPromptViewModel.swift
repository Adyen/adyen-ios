//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit
#if canImport(AdyenUI)
    import AdyenUI
#endif

@MainActor
internal final class StoredPaymentPromptViewModel: ObservableObject {

    internal let theme: CheckoutTheme
    internal weak var router: StoredPaymentPromptRouting?

    internal let mode: StoredPaymentPromptMode
    private let logoURLProvider: LogoURLProvider
    private let localizationParameters: LocalizationParameters?
    private let dropInFlowManager: DropInFlowManaging

    internal init(
        mode: StoredPaymentPromptMode,
        theme: CheckoutTheme,
        logoURLProvider: LogoURLProvider,
        localizationParameters: LocalizationParameters?,
        dropInFlowManager: DropInFlowManaging
    ) {
        self.mode = mode
        self.theme = theme
        self.logoURLProvider = logoURLProvider
        self.localizationParameters = localizationParameters
        self.dropInFlowManager = dropInFlowManager
        component.delegate = self
    }

    // MARK: - Content

    internal var title: String {
        switch mode {
        case .input:
            isStoredCard ? localizedString(.cardCvcItemTitle, localizationParameters) : displayInformation.title
        }
    }

    internal var subtitle: NSAttributedString {
        switch mode {
        case .input:
            inputSubtitle
        }
    }

    internal var backButtonTitle: String {
        localizedString(.backButton, localizationParameters)
    }

    internal var paymentMethodLogoURL: URL {
        logoURLProvider.logoURL(withName: displayInformation.logoName)
    }

    /// The controller of the component that owns the input, if any.
    internal var componentViewController: UIViewController? {
        switch mode {
        case let .input(component):
            component.viewController
        }
    }

    // MARK: - Lifecycle

    internal func didAppear() {
        dropInFlowManager.setLoadingPresenter(self)
    }

    internal func didDisappear() {
        dropInFlowManager.setLoadingPresenter(nil)
    }

    // MARK: - Actions

    internal func cancel() {
        dropInFlowManager.setLoadingPresenter(nil)
        dropInFlowManager.cancel(component: component)
        router?.dismiss()
    }

    internal func stopLoading() {
        component.stopLoading()
    }

    // MARK: - Private

    private var component: PaymentComponent {
        mode.component
    }

    private var isStoredCard: Bool {
        component.paymentMethod is StoredCardPaymentMethod
    }

    private var displayInformation: DisplayInformation {
        component.paymentMethod.displayInformation(using: localizationParameters)
    }

    private var positiveAmount: Amount? {
        component.context.amount.flatMap { $0.value > 0 ? $0 : nil }
    }

    private var inputSubtitle: NSAttributedString {
        guard isStoredCard else {
            let text = localizedString(
                .preselectedPaymentMethodSubtitle,
                localizationParameters,
                component.paymentMethod.name
            )
            return makeAttributedString(text)
        }

        let paymentMethodTitle = "\(component.paymentMethod.name) \(displayInformation.title)"
        let amount = positiveAmount
        let text = if let amount {
            localizedString(
                .checkoutDropinAuthenticationInputDescription,
                localizationParameters,
                paymentMethodTitle,
                amount.formatted
            )
        } else {
            localizedString(.cardSecurityCodeDescription, localizationParameters, paymentMethodTitle)
        }
        return makeAttributedString(
            text,
            emphasizedValues: [paymentMethodTitle, amount?.formatted].compactMap { $0 }
        )
    }

    /// Builds the subtitle, emphasizing the given values when the translation contains them.
    ///
    /// Emphasized values are looked up in the translated text, so a translation that drops or
    /// rewrites a placeholder simply renders without emphasis instead of failing.
    private func makeAttributedString(
        _ text: String,
        emphasizedValues: [String] = []
    ) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: theme.elements.labels.body.font,
                .foregroundColor: theme.elements.labels.body.color
            ]
        )
        emphasizedValues.forEach {
            let range = (text as NSString).range(of: $0)
            guard range.location != NSNotFound else { return }
            attributedString.addAttributes(
                [
                    .font: theme.elements.labels.bodyEmphasized.font,
                    .foregroundColor: theme.elements.labels.bodyEmphasized.color
                ],
                range: range
            )
        }
        return attributedString
    }
}

extension StoredPaymentPromptViewModel: LoadControllable {}

extension StoredPaymentPromptViewModel: PaymentComponentDelegate {

    internal func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent) {
        dropInFlowManager.submit(data, from: component, actionPresenter: self)
    }

    internal func didFail(with error: any Error, from component: any PaymentComponent) {
        if case ComponentError.cancelled = error {
            cancel()
        } else {
            dropInFlowManager.fail(with: error, from: component)
        }
    }
}

extension StoredPaymentPromptViewModel: ActionPresenter {

    internal func present(actionViewController: UIViewController) {
        router?.present(actionViewController: actionViewController) { [weak self] in
            self?.cancel()
        }
    }

    internal func didCancel(actionComponent: any ActionComponent) {
        cancel()
    }
}
