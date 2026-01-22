//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenSession)
    @_spi(AdyenInternal) import AdyenSession
#endif
#if canImport(AdyenDropIn)
    @_spi(AdyenInternal) import AdyenDropIn
#endif
import AdyenNetworking

internal protocol AdyenCheckoutProtocol {
    
    func createPaymentComponent(for type: PaymentMethodType) -> CheckoutPaymentComponent?
    
    func createPaymentComponent(for identifier: String) -> CheckoutPaymentComponent?
    
    func createDropIn() -> DropInComponent?
}

internal protocol AdyenCheckoutProviding: AdyenSessionProviding, CheckoutAttemptIdProviding {
    func setup(
        with sessionResponse: SessionResponse,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate?
    ) async throws -> AdyenCheckout
    
    func setup(
        with paymentMethods: PaymentMethods,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate?
    ) async throws -> AdyenCheckout
}

internal protocol AdyenSessionProviding {
    func setupSession(
        with sessionResponse: SessionResponse,
        configuration: CheckoutConfiguration,
        apiClient: APIClientProtocol
    ) async throws -> SessionProtocol
}

internal protocol CheckoutAttemptIdProviding {
    func fetchCheckoutAttemptId(
        with configuration: CheckoutConfiguration,
        apiClient: APIClientProtocol
    ) async throws -> String
}
