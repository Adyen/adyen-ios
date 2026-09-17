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
internal protocol AuthenticationWithInputAssemblerProtocol {
    func resolveAuthenticationWithInputRouter(
        for component: PaymentComponent,
        presentationMode: AuthenticationPresentationMode,
        listener: AuthenticationWithInputRouterListener
    ) -> Router
}

@MainActor
internal struct AuthenticationWithInputAssembler: AuthenticationWithInputAssemblerProtocol {

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

    internal func resolveAuthenticationWithInputRouter(
        for component: PaymentComponent,
        presentationMode: AuthenticationPresentationMode,
        listener: AuthenticationWithInputRouterListener
    ) -> Router {
        let viewModel = AuthenticationWithInputViewModel(
            component: component,
            theme: theme,
            logoURLProvider: logoURLProvider,
            localizationParameters: localizationParameters,
            dropInFlowManager: dropInFlowManager
        )
        let viewController = UIHostingController(
            rootView: AuthenticationWithInputView(viewModel: viewModel)
        )
        viewController.isModalInPresentation = true
        let router = AuthenticationWithInputRouter(
            viewController: viewController,
            presentationMode: presentationMode,
            listener: listener
        )
        viewModel.router = router
        return router
    }
}
