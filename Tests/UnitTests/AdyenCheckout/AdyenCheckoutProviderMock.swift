//
// Copyright (c) Adyen N.V.
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
    var mockedSessionResult: Result<SessionProtocol, Error>?
    // For CheckoutAttemptIdProviding
    var mockedCheckoutAttemptId: Result<String, Error>?
    
    func setupSession(
        with sessionResponse: SessionResponse,
        configuration: CheckoutConfiguration,
        apiClient: APIClientProtocol
    ) async throws -> SessionProtocol {
        
        switch mockedSessionResult {
        case let .success(session):
            return session
        case let .failure(error):
            throw error
        case nil:
            throw TestError()
        }
    }
    
    func fetchCheckoutAttemptId(
        with configuration: CheckoutConfiguration,
        apiClient: APIClientProtocol
    ) async throws -> String {
        
        switch mockedCheckoutAttemptId {
        case let .success(attemptId):
            return attemptId
        case let .failure(error):
            throw error
        case nil:
            throw TestError()
        }

    }
    
    // Convenience for direct AdyenCheckoutProviding use
    func setup(
        with sessionResponse: SessionResponse,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate?
    ) async throws -> AdyenCheckout {
        setupSessionCalled = true
        
        switch setupWithSessionResult {
        case let .success(checkout):
            return checkout
        case let .failure(error):
            throw error
        case nil:
            throw TestError()
        }
    }
    
    func setup(
        with paymentMethods: PaymentMethods,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate?
    ) async throws -> AdyenCheckout {
        setupPaymentMethodsCalled = true
        
        switch setupWithPaymentMethodsResult {
        case let .success(checkout):
            return checkout
        case let .failure(error):
            throw error
        case nil:
            throw TestError()
        }
    }
}
