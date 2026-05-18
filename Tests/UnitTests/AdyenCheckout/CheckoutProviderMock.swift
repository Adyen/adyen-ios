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

internal class CheckoutProviderMock: CheckoutProviding {
    var setupSessionCalled = false
    var setupWithSessionResult: Result<CheckoutCoreProtocol, Error>?
    
    var setupPaymentMethodsCalled = false
    var setupWithPaymentMethodsResult: Result<CheckoutCoreProtocol, Error>?
    
    var setupActionOnlyCalled = false
    var setupActionOnlyResult: Result<CheckoutCoreProtocol, Error>?
    
    /// For AdyenSessionProviding
    var mockedSessionResult: Result<SessionProtocol, Error>?
    
    func setupSession(
        with sessionResponse: SessionResponse,
        adyenContext: AdyenContext,
        apiClient: AsyncAPIClientProtocol
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
    
    /// Convenience for direct CheckoutProviding use
    func setup(
        with sessionResponse: SessionResponse,
        configuration: CheckoutConfiguration,
        callbacks: SessionCheckoutCallbacks,
        presentationDelegate: PresentationDelegate?
    ) async throws -> CheckoutCoreProtocol {
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
        callbacks: AdvancedCheckoutCallbacks,
        presentationDelegate: PresentationDelegate?
    ) async throws -> CheckoutCoreProtocol {
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
    
    func setup(
        configuration: CheckoutConfiguration,
        callbacks: ActionOnlyCheckoutCallbacks,
        presentationDelegate: PresentationDelegate?
    ) async throws -> CheckoutCoreProtocol {
        setupActionOnlyCalled = true
        
        switch setupActionOnlyResult {
        case let .success(checkout):
            return checkout
        case let .failure(error):
            throw error
        case nil:
            throw TestError()
        }
    }
}
