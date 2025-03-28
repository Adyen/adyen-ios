//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenDropIn
@_spi(AdyenInternal) import AdyenSession
@_spi(AdyenInternal) import AdyenNetworking

public class AdyenCheckout {
    
    internal var session: AdyenSession?
    internal var checkoutAttemptId: String?
    internal var apiClient: APIClient?
    internal var paymentMethods: PaymentMethods?
    
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
        completion: @escaping (AdyenCheckout) -> Void
    ) {
        // session
        // analytics
        var checkout = AdyenCheckout()
        let apiClient = APIClient(apiContext: configuration.apiContext)
        
        let group = DispatchGroup()
        group.enter()
        // create and store session and paymentmethods
        group.leave()
        
        group.enter()
        // fetch and store checkout attempt id
        group.leave()
        
        group.notify(queue: .main) {
            completion(checkout)
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
        completion: @escaping (AdyenCheckout) -> Void
    ) {
        var checkout = AdyenCheckout()
        checkout.paymentMethods = paymentMethods
        let apiClient = APIClient(apiContext: configuration.apiContext)
        
        // fetch and store checkout attempt id
        completion(checkout)
    }
}
