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
        AmountAwarePaymentStringsPolicy.storedPaymentMethodAttributedSubtitle(
            for: component.paymentMethod.name,
            with: component.context.amount,
            localizationParameters: localizationParameters,
            attributes: [
                .font: theme.elements.labels.body.font,
                .foregroundColor: theme.elements.labels.body.color
            ],
            emphasizedAttributes: [
                .font: theme.elements.labels.bodyEmphasized.font,
                .foregroundColor: theme.elements.labels.bodyEmphasized.color
            ]
        )
    }

    internal var paymentMethodLogoURL: URL {
        logoURLProvider.logoURL(withName: displayInformation.logoName)
    }

    internal var componentViewController: UIViewController {
        component.viewController
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

    private var displayInformation: DisplayInformation {
        component.paymentMethod.displayInformation(using: localizationParameters)
    }
}

extension StoredPaymentMethodContentViewModel: LoadControllable {}

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
