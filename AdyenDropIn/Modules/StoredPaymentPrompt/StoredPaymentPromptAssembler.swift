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
internal protocol StoredPaymentPromptAssemblerProtocol {

    /// Resolves the router for the prompt that lets the shopper complete a stored payment.
    ///
    /// - Returns: The router, or `nil` when the component cannot be completed through a prompt,
    ///            in which case the parent module decides how to present it.
    func resolveStoredPaymentPromptRouter(
        for component: PaymentComponent,
        presentationMode: StoredPaymentPromptPresentationMode,
        listener: StoredPaymentPromptRouterListener
    ) -> Router?
}

@MainActor
internal struct StoredPaymentPromptAssembler: StoredPaymentPromptAssemblerProtocol {

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

    internal func resolveStoredPaymentPromptRouter(
        for component: PaymentComponent,
        presentationMode: StoredPaymentPromptPresentationMode,
        listener: StoredPaymentPromptRouterListener
    ) -> Router? {
        guard let mode = resolveMode(for: component) else { return nil }

        let viewModel = StoredPaymentPromptViewModel(
            mode: mode,
            theme: theme,
            logoURLProvider: logoURLProvider,
            localizationParameters: localizationParameters,
            dropInFlowManager: dropInFlowManager
        )
        let viewController = UIHostingController(
            rootView: StoredPaymentPromptView(viewModel: viewModel)
        )
        let router = StoredPaymentPromptRouter(
            viewController: viewController,
            presentationMode: presentationMode,
            listener: listener
        )
        viewModel.router = router
        return router
    }

    private func resolveMode(for component: PaymentComponent) -> StoredPaymentPromptMode? {
        guard component.requiresUserInteraction else { return nil }
        return .input(component)
    }
}
