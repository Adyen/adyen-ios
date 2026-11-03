//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenUI
import Combine
import Foundation
import SwiftUI

// sourcery:AutoMockable
@MainActor
internal protocol GenericPaymentMethodAssemblerProtocol {
    func resolveGenericPaymentMethodRouter(
        for component: PaymentComponent,
        listener: GenericPaymentMethodRouterListener
    ) -> Router
}

@MainActor
internal struct GenericPaymentMethodAssembler: GenericPaymentMethodAssemblerProtocol {

    // MARK: - Properties

    private let dropInFlowManager: DropInFlowManaging
    private let logoURLProvider: LogoURLProvider
    private let theme: CheckoutTheme
    private let localizationParameters: LocalizationParameters

    // MARK: - Initializers

    internal init(
        dropInFlowManager: DropInFlowManaging,
        logoURLProvider: LogoURLProvider,
        theme: CheckoutTheme,
        localizationParameters: LocalizationParameters
    ) {
        self.dropInFlowManager = dropInFlowManager
        self.logoURLProvider = logoURLProvider
        self.theme = theme
        self.localizationParameters = localizationParameters
    }

    // MARK: - GenericPaymentMethodAssemblerProtocol

    internal func resolveGenericPaymentMethodRouter(
        for component: PaymentComponent,
        listener: GenericPaymentMethodRouterListener
    ) -> Router {
        let viewModel = GenericPaymentMethodViewModel(
            component: component,
            dropInFlowManager: dropInFlowManager,
            logoUrlProvider: logoURLProvider,
            localizationParameters: localizationParameters
        )
        let genericPaymentMethodViewController = NavigationLockingHostingController(
            rootView: GenericPaymentMethodView(viewModel: viewModel, theme: theme),
            isPaymentInProgress: viewModel.isNavigationLocked,
            onPop: { viewModel.dismiss() }
        )

        let router = GenericPaymentMethodRouter(
            viewController: genericPaymentMethodViewController,
            listener: listener
        )
        viewModel.router = router
        return router
    }

}
