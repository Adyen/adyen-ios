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

    internal var header: PaymentMethodContentHeaderViewModel {
        PaymentMethodContentHeaderViewModel(
            paymentMethod: component.paymentMethod,
            context: component.context,
            localizationParameters: localizationParameters,
            theme: theme,
            logoURLProvider: logoURLProvider
        )
    }

    internal var componentViewController: UIViewController {
        component.viewController
    }

    // MARK: - Actions

    internal func cancel() {
        dropInFlowManager.cancel(component: component)
        router?.dismiss()
    }
}

extension StoredPaymentMethodContentViewModel: PaymentComponentDelegate {

    internal func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent) {
        dropInFlowManager.submit(data, from: component)
    }

    internal func didFail(with error: any Error, from component: any PaymentComponent) {
        if case ComponentError.cancelled = error {
            cancel()
        } else {
            dropInFlowManager.fail(with: error, from: component)
        }
    }
}
