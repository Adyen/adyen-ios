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
internal protocol StoredPaymentMethodContentRouting: AnyObject {
    func present(actionViewController: UIViewController, onCancel: (() -> Void)?)
    func dismiss()
}

@MainActor
internal final class StoredPaymentMethodContentViewModel {

    internal let theme: CheckoutTheme
    internal weak var router: StoredPaymentMethodContentRouting?

    private let component: any StoredPaymentComponent
    private let logoURLProvider: LogoURLProvider
    private let localizationParameters: LocalizationParameters?
    private let dropInFlowManager: DropInFlowManaging

    internal init(
        component: any StoredPaymentComponent,
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
    }

    // MARK: - Content

    internal var title: String {
        displayInformation.title
    }

    internal var subtitle: NSAttributedString {
        let paymentMethodName = component.paymentMethod.name
        let text = AmountAwarePaymentStringsPolicy.storedPaymentMethodSubtitle(
            for: paymentMethodName,
            with: component.context.amount,
            localizationParameters: localizationParameters
        )
        let emphasizedValues = [paymentMethodName, positiveAmount?.formatted].compactMap { $0 }
        return makeAttributedString(text, emphasizedValues: emphasizedValues)
    }

    internal var paymentMethodLogoURL: URL {
        logoURLProvider.logoURL(withName: displayInformation.logoName)
    }

    internal var componentViewController: UIViewController {
        component.viewController
    }

    // MARK: - Actions

    internal func cancel() {
        dropInFlowManager.cancel(component: component)
        router?.dismiss()
    }

    // MARK: - Private

    private var displayInformation: DisplayInformation {
        component.paymentMethod.displayInformation(using: localizationParameters)
    }

    private var positiveAmount: Amount? {
        guard var amount = component.context.amount, amount.value > 0 else { return nil }
        amount.localeIdentifier = amount.localeIdentifier ?? localizationParameters?.locale
        return amount
    }

    private func makeAttributedString(
        _ text: String,
        emphasizedValues: [String]
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

extension StoredPaymentMethodContentViewModel: PaymentComponentDelegate {

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

extension StoredPaymentMethodContentViewModel: ActionPresenter {

    internal func present(actionViewController: UIViewController) {
        router?.present(actionViewController: actionViewController) { [weak self] in
            self?.cancel()
        }
    }

    internal func didCancel(actionComponent: any ActionComponent) {
        cancel()
    }
}
