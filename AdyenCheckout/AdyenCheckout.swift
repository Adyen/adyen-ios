//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenDropIn
@_spi(AdyenInternal) import AdyenSession
@_spi(AdyenInternal) import AdyenActions
@_spi(AdyenInternal) import AdyenNetworking
import Foundation

/// AdyenCheckout is the entry point to the Checkout flow. You initialize it through its static methods for your chosen flow
/// and it prepares all the requied data asynchronously and returns an `AdyenCheckout` instance ready to be used.
public final class AdyenCheckout: AdyenCheckoutProtocol {
    
    internal var session: AdyenSession?
    internal var checkoutAttemptId: String?
    internal var paymentMethods: PaymentMethods?
    internal let configuration: CheckoutConfiguration
    
    /// Sets up the checkout object for the default flow
    /// with the values from your backend's `/session` call.
    /// - Parameters:
    ///   - sessionId: sessionId from the `/session` call response.
    ///   - sessionData: session data from the `/session` call response.
    ///   - configuration: The `CheckoutConfiguration` instance.
    ///   - completion: A closure that is called when the setup is complete, containing the checkout object.
    public static func setup(
        with sessionId: String,
        sessionData: String,
        configuration: CheckoutConfiguration,
        completion: @escaping (Result<AdyenCheckout, Error>) -> Void
    ) {
        // session
        // analytics
        let checkout = AdyenCheckout(configuration: configuration)
        
        let group = DispatchGroup()
        
        // create and store session and paymentmethods
        group.enter()
        setupSession(with: configuration) { result in
            switch result {
            case let .success(session):
                checkout.session = session
                checkout.paymentMethods = session.sessionContext.paymentMethods
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
                checkout.checkoutAttemptId = attemptId
            case .failure:
                // TODO: decide what to do for failed attempt
                break
            }
            group.leave()
        }
        
        // success case only for now
        group.notify(queue: .main) {
            completion(.success(checkout))
        }
    }
    
    /// Sets up the checkout object for the advanced flow
    /// with the values from your backend's `/paymentMethods` call.
    /// - Parameters:
    ///   - paymentMethods: The `PaymentMethods` response from the `/paymentMethods` call.
    ///   - configuration: The `CheckoutConfiguration` instance.
    ///   - completion: A closure that is called when the setup is complete, containing the checkout object.
    public static func setup(
        with paymentMethods: PaymentMethods,
        configuration: CheckoutConfiguration,
        completion: @escaping (Result<AdyenCheckout, Error>) -> Void
    ) {
        let checkout = AdyenCheckout(configuration: configuration)
        checkout.paymentMethods = paymentMethods
        
        // fetch and store checkout attempt id
        fetchCheckoutAttemptId(with: configuration) { result in
            switch result {
            case let .success(attemptId):
                checkout.checkoutAttemptId = attemptId
            case .failure:
                // TODO: decide what to do for failed attempt
                break
            }
        }
        completion(.success(checkout))
    }
    
    public func createComponent(with paymentMethod: any PaymentMethod) -> AdyenCheckoutComponent? {
        try? CheckoutComponentBuilder.build(for: paymentMethod, configuration: configuration)
//        AdyenCheckoutComponent(paymentMethod: paymentMethod, configuration: configuration)
    }
    
    public func createComponent(with action: Action) -> AdyenCheckoutComponent? {
        CheckoutComponentBuilder.build(for: action, configuration: configuration)
    }
    
    public func createDropIn() -> DropInComponent? {
        nil
    }
    
    // MARK: Internal

    internal init(configuration: CheckoutConfiguration) {
        self.configuration = configuration
    }
    
    internal static func setupSession(
        with configuration: CheckoutConfiguration,
        order: PartialPaymentOrder? = nil,
        completion: @escaping (Result<AdyenSession, Error>) -> Void
    ) {}
    
    internal static func fetchCheckoutAttemptId(
        with configuration: CheckoutConfiguration,
        completion: @escaping (Result<String, Error>) -> Void
    ) {}
}
