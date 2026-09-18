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
internal final class AuthenticationWithInputViewModel: ObservableObject {

    internal let theme: CheckoutTheme
    internal weak var router: AuthenticationWithInputRouting?

    private let component: PaymentComponent
    private let logoURLProvider: LogoURLProvider
    private let localizationParameters: LocalizationParameters?
    private let dropInFlowManager: DropInFlowManaging

    internal init(
        component: PaymentComponent,
        theme: CheckoutTheme,
        logoURLProvider: LogoURLProvider,
        localizationParameters: LocalizationParameters?,
        dropInFlowManager: DropInFlowManaging
    ) {
        self.component = component
        self.theme = theme
        self.logoURLProvider = logoURLProvider
        self.localizationParameters = localizationParameters
        self.dropInFlowManager = dropInFlowManager
        component.delegate = self
        dropInFlowManager.setLoadingPresenter(self)
    }

    internal var title: String {
        guard component.paymentMethod is StoredCardPaymentMethod else {
            return displayInformation.title
        }
        return localizedString(.cardCvcItemTitle, localizationParameters)
    }

    internal var backButtonTitle: String {
        localizedString(.backButton, localizationParameters)
    }

    internal var subtitle: NSAttributedString {
        guard component.paymentMethod is StoredCardPaymentMethod else {
            let text = localizedString(
                .preselectedPaymentMethodSubtitle,
                localizationParameters,
                component.paymentMethod.name
            )
            return makeAttributedString(text)
        }

        let paymentMethodTitle = "\(component.paymentMethod.name) \(displayInformation.title)"
        let amount = component.context.amount.flatMap { $0.value > 0 ? $0 : nil }
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

    internal var paymentMethodLogoURL: URL {
        logoURLProvider.logoURL(withName: displayInformation.logoName)
    }

    internal var componentViewController: UIViewController {
        component.viewController
    }

    internal func cancel() {
        dropInFlowManager.setLoadingPresenter(nil)
        dropInFlowManager.cancel(component: component)
        router?.dismiss()
    }

    internal func stopLoading() {
        component.stopLoading()
    }

    private var displayInformation: DisplayInformation {
        component.paymentMethod.displayInformation(using: localizationParameters)
    }

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

extension AuthenticationWithInputViewModel: LoadControllable {}

extension AuthenticationWithInputViewModel: PaymentComponentDelegate {

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

extension AuthenticationWithInputViewModel: ActionPresenter {

    internal func present(actionViewController: UIViewController) {
        router?.present(actionViewController: actionViewController) { [weak self] in
            self?.cancel()
        }
    }

    internal func didCancel(actionComponent: any ActionComponent) {
        cancel()
    }
}
