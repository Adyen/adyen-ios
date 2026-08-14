//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif
import Foundation
import UIKit

@MainActor
// swiftlint:disable:next type_name
internal protocol StoredPaymentMethodManagementAssemblerProtocol {
    func resolveStoredPaymentMethodManagementRouter(
        paymentMethods: [any StoredPaymentMethod],
        capability: StoredPaymentMethodManagementCapability,
        listener: StoredPaymentMethodManagementListener
    ) -> Router
}

@MainActor
internal struct StoredPaymentMethodManagementAssembler: StoredPaymentMethodManagementAssemblerProtocol {

    // MARK: - Properties

    private let localizationParameters: LocalizationParameters?
    private let logoURLProvider: LogoURLProvider
    private let theme: CheckoutTheme

    // MARK: - Initializers

    internal init(
        localizationParameters: LocalizationParameters?,
        logoURLProvider: LogoURLProvider,
        theme: CheckoutTheme
    ) {
        self.localizationParameters = localizationParameters
        self.logoURLProvider = logoURLProvider
        self.theme = theme
    }

    // MARK: - StoredPaymentMethodManagementAssemblerProtocol

    internal func resolveStoredPaymentMethodManagementRouter(
        paymentMethods: [any StoredPaymentMethod],
        capability: StoredPaymentMethodManagementCapability,
        listener: StoredPaymentMethodManagementListener
    ) -> Router {
        let mapper = StoredPaymentMethodManagementPresentationMapper(
            localizationParameters: localizationParameters,
            logoURLProvider: logoURLProvider
        )
        let viewModel = StoredPaymentMethodManagementViewModel(
            paymentMethods: paymentMethods,
            capability: capability,
            mapper: mapper,
            localizationParameters: localizationParameters
        )
        let hostingController = StoredPaymentMethodManagementHostingController(viewModel: viewModel, theme: theme)
        let router = StoredPaymentMethodManagementRouter(
            rootViewController: hostingController,
            listener: listener
        )

        viewModel.router = router
        hostingController.onDismissFromNavigation = { [weak router] in
            router?.didDismissFromNavigation()
        }

        return router
    }
}
