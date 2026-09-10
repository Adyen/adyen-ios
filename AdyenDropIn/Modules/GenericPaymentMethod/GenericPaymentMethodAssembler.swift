//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenUI
import Foundation
import SwiftUI

@MainActor
internal protocol GenericPaymentMethodAssemblerProtocol {
    func resolveGenericPaymentMethodRouter(
        for component: PaymentComponent
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
        for component: PaymentComponent
    ) -> Router {
        let viewModel = GenericPaymentMethodViewModel(
            component: component,
            dropInFlowManager: dropInFlowManager,
            logoUrlProvider: logoURLProvider,
            localizationParameters: localizationParameters
        )
        let genericPaymentMethodView = GenericPaymentMethodView(viewModel: viewModel, theme: theme)
        let genericPaymentMethodViewController = UIHostingController(rootView: genericPaymentMethodView)

        let router = GenericPaymentMethodRouter(viewController: genericPaymentMethodViewController)
        viewModel.router = router
        return router
    }

}
