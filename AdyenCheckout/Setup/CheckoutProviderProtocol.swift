//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenSession)
    import AdyenSession
#endif
import AdyenNetworking
import Foundation

internal protocol CheckoutProviding: AdyenSessionProviding {
    func setup(
        with sessionResponse: SessionResponse,
        configuration: CheckoutConfiguration,
        callbackStore: SessionCheckoutCallbackStore,
        presentationDelegate: PresentationDelegate?
    ) async throws -> CheckoutCoreProtocol

    func setup(
        with paymentMethods: PaymentMethods,
        configuration: CheckoutConfiguration,
        callbackStore: AdvancedCheckoutCallbackStore,
        presentationDelegate: PresentationDelegate?
    ) async throws -> CheckoutCoreProtocol

    func setup(
        configuration: CheckoutConfiguration,
        callbackStore: ActionOnlyCheckoutCallbackStore,
        presentationDelegate: PresentationDelegate?
    ) async throws -> CheckoutCoreProtocol
}

internal protocol AdyenSessionProviding {
    func setupSession(
        with sessionResponse: SessionResponse,
        adyenContext: AdyenContext,
        apiClient: AsyncAPIClientProtocol
    ) async throws -> SessionProtocol
}
