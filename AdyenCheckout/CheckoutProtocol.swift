//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenSession)
    import AdyenSession
#endif
#if canImport(AdyenDropIn)
    import AdyenDropIn
#endif
import AdyenNetworking

@MainActor
internal protocol CheckoutProtocol {
    
    func createPaymentComponent(for type: PaymentMethodType) throws -> CheckoutPaymentComponent
    
    func createPaymentComponent(for identifier: String) throws -> CheckoutPaymentComponent
    
    func createDropIn() -> DropInComponent?
}

internal protocol CheckoutProviding: AdyenSessionProviding {
    func setup(
        with sessionResponse: SessionResponse,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate?
    ) async throws -> Checkout
    
    func setup(
        with paymentMethods: PaymentMethods,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate?
    ) async throws -> Checkout
    
    func setup(
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate?
    ) async throws -> Checkout
}

internal protocol AdyenSessionProviding {
    func setupSession(
        with sessionResponse: SessionResponse,
        adyenContext: AdyenContext,
        apiClient: AsyncAPIClientProtocol
    ) async throws -> SessionProtocol
}
