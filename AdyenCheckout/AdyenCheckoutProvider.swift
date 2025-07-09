//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenSession
@_spi(AdyenInternal) import AdyenDropIn
@_spi(AdyenInternal) import AdyenActions
import AdyenNetworking
import Foundation

/// Plain static provider layer to create the AdyenCheckout object.
internal class AdyenCheckoutProvider: AdyenCheckoutProviding {
    
    private init() {}
    
    internal static let `default` = AdyenCheckoutProvider()
    
    internal func setup(
        with sessionId: String,
        sessionData: String,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate? = nil,
        completion: @escaping (Result<AdyenCheckout, Error>) -> Void
    ) {
        var checkoutAttemptIdInstance: String?
        var sessionInstance: AdyenSessionProtocol?
        let group = DispatchGroup()
        
        // create and store session and payment methods
        group.enter()
        setupSession(with: configuration) { result in
            switch result {
            case let .success(session):
                sessionInstance = session
            case .failure:
                // TODO: add error
                break
            }
            group.leave()
        }
        
        // fetch and store checkout attempt id
        group.enter()
        fetchCheckoutAttemptId(with: configuration) { result in
            switch result {
            case let .success(attemptId):
                checkoutAttemptIdInstance = attemptId
            case .failure:
                // TODO: decide what to do for failed attempt
                break
            }
            group.leave()
        }
        
        // success case only for now
        group.notify(queue: .main) {
            let checkout = AdyenCheckout(
                configuration: configuration,
                session: sessionInstance,
                checkoutAttemptId: checkoutAttemptIdInstance,
                presentationDelegate: presentationDelegate
            )
            completion(.success(checkout))
        }
    }
    
    /// Sets up the checkout object for the advanced flow
    /// with the values from your backend's `/paymentMethods` call.
    /// - Parameters:
    ///   - paymentMethods: The `PaymentMethods` response from the `/paymentMethods` call.
    ///   - configuration: The `CheckoutConfiguration` instance.
    ///   - presentationDelegate: A delegate in order to handle presentation logic if needed.
    ///   - completion: A closure that is called when the setup is complete, containing the checkout object.
    internal func setup(
        with paymentMethods: PaymentMethods,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate? = nil,
        completion: @escaping (Result<AdyenCheckout, Error>) -> Void
    ) {
        var checkoutAttemptIdInstance: String?
        
        // fetch and store checkout attempt id
        fetchCheckoutAttemptId(with: configuration) { result in
            switch result {
            case let .success(attemptId):
                checkoutAttemptIdInstance = attemptId
            case .failure:
                // TODO: decide what to do for failed attempt
                break
            }
        }
        
        let checkout = AdyenCheckout(
            configuration: configuration,
            paymentMethods: paymentMethods,
            checkoutAttemptId: checkoutAttemptIdInstance,
            presentationDelegate: presentationDelegate
        )
        
        completion(.success(checkout))
    }
    
    // MARK: Internal
    
    internal func setupSession(
        with configuration: CheckoutConfiguration,
        order: PartialPaymentOrder? = nil,
        completion: @escaping (Result<AdyenSessionProtocol, Error>) -> Void
    ) {}
    
    internal func fetchCheckoutAttemptId(
        with configuration: CheckoutConfiguration,
        completion: @escaping (Result<String, Error>) -> Void
    ) {}
}
