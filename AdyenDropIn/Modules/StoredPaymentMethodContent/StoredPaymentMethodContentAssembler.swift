//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif
import SwiftUI

@MainActor
internal protocol StoredPaymentMethodContentAssembling {

    /// Resolves the router for the content that lets the shopper complete a stored payment.
    ///
    /// - Returns: The router, or `nil` when the component cannot be completed through this content,
    ///            in which case the parent module decides how to present it.
    func resolveStoredPaymentMethodContentRouter(
        for component: PaymentComponent,
        presentationMode: StoredPaymentMethodContentPresentation,
        listener: StoredPaymentMethodContentRouterListener
    ) -> Router?
}

@MainActor
internal struct StoredPaymentMethodContentAssembler: StoredPaymentMethodContentAssembling {

    private let dropInFlowManager: DropInFlowManaging
    private let logoURLProvider: LogoURLProvider
    private let theme: CheckoutTheme
    private let localizationParameters: LocalizationParameters?

    internal init(
        dropInFlowManager: DropInFlowManaging,
        logoURLProvider: LogoURLProvider,
        theme: CheckoutTheme,
        localizationParameters: LocalizationParameters?
    ) {
        self.dropInFlowManager = dropInFlowManager
        self.logoURLProvider = logoURLProvider
        self.theme = theme
        self.localizationParameters = localizationParameters
    }

    internal func resolveStoredPaymentMethodContentRouter(
        for component: PaymentComponent,
        presentationMode: StoredPaymentMethodContentPresentation,
        listener: StoredPaymentMethodContentRouterListener
    ) -> Router? {
        guard let component = component as? any StoredPaymentComponent else { return nil }

        let viewModel = StoredPaymentMethodContentViewModel(
            component: component,
            theme: theme,
            logoURLProvider: logoURLProvider,
            localizationParameters: localizationParameters,
            dropInFlowManager: dropInFlowManager
        )
        let viewController = UIHostingController(
            rootView: StoredPaymentMethodContentView(viewModel: viewModel)
        )
        let router = StoredPaymentMethodContentRouter(
            viewController: viewController,
            presentationMode: presentationMode,
            listener: listener
        )
        viewModel.router = router
        return router
    }

}
