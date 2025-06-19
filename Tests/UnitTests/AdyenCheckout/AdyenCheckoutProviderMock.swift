//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenCheckout
@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenSession
@_spi(AdyenInternal) @testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenActions
import AdyenNetworking

internal class AdyenCheckoutProviderMock: AdyenCheckoutProviding {
    var setupSessionCalled = false
    var setupWithSessionResult: Result<AdyenCheckout, Error>?
    
    var setupPaymentMethodsCalled = false
    var setupWithPaymentMethodsResult: Result<AdyenCheckout, Error>?
    
    // For AdyenSessionProviding
    var setupSessionHandler: ((CheckoutConfiguration, PartialPaymentOrder?, @escaping (Result<AdyenSession, Error>) -> Void) -> Void)?
    // For CheckoutAttemptIdProviding
    var fetchCheckoutAttemptIdHandler: ((CheckoutConfiguration, @escaping (Result<String, Error>) -> Void) -> Void)?
    
    func setupSession(
        with configuration: CheckoutConfiguration,
        order: PartialPaymentOrder?,
        completion: @escaping (Result<AdyenSession, Error>) -> Void
    ) {
        setupSessionCalled = true
        setupSessionHandler?(configuration, order, completion)
    }
    
    func fetchCheckoutAttemptId(
        with configuration: CheckoutConfiguration,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        fetchCheckoutAttemptIdHandler?(configuration, completion)
    }
    
    // Convenience for direct AdyenCheckoutProviding use
    func setup(
        with sessionId: String,
        sessionData: String,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate?,
        completion: @escaping (Result<AdyenCheckout, Error>) -> Void
    ) {
        setupSessionCalled = true
        if let result = setupWithSessionResult {
            completion(result)
        }
    }
    
    func setup(
        with paymentMethods: PaymentMethods,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate?,
        completion: @escaping (Result<AdyenCheckout, Error>) -> Void
    ) {
        setupPaymentMethodsCalled = true
        if let result = setupWithPaymentMethodsResult {
            completion(result)
        }
    }
}
