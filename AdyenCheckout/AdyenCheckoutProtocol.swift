//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenSession
@_spi(AdyenInternal) import AdyenDropIn
@_spi(AdyenInternal) import AdyenActions

internal protocol AdyenCheckoutProtocol: AdyenSessionProviding, CheckoutAttemptIdProviding {
    static func setup(
        with sessionId: String,
        sessionData: String,
        configuration: CheckoutConfiguration,
        completion: @escaping (Result<AdyenCheckout, Error>) -> Void
    )
    
    static func setup(
        with paymentMethods: PaymentMethods,
        configuration: CheckoutConfiguration,
        completion: @escaping (Result<AdyenCheckout, Error>) -> Void
    )
    
    func createComponent(with paymentMethod: PaymentMethod) -> AdyenCheckoutComponent?
    
    func createComponent(with action: Action) -> AdyenCheckoutComponent?
    
    func createDropIn() -> DropInComponent?
}

internal protocol AdyenSessionProviding {
    static func setupSession(
        with configuration: CheckoutConfiguration,
        order: PartialPaymentOrder?,
        completion: @escaping (Result<AdyenSession, Error>) -> Void
    )
}

internal protocol CheckoutAttemptIdProviding {
    
    static func fetchCheckoutAttemptId(
        with configuration: CheckoutConfiguration,
        completion: @escaping (Result<String, Error>) -> Void
    )
}
