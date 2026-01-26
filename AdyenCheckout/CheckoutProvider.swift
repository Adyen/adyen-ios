//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenSession)
    @_spi(AdyenInternal) import AdyenSession
#endif
import AdyenNetworking
import Foundation

/// Plain static provider layer to create the Checkout object.
internal class CheckoutProvider: CheckoutProviding {
    
    private init() {}
    
    internal static let `default` = CheckoutProvider()
    
    internal func setup(
        with sessionId: String,
        sessionData: String,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate?
    ) async throws -> Checkout {
        
        let apiClient = APIClient(apiContext: configuration.context.apiContext)
        
        // create and store session and payment methods
        async let session = setupSession(
            with: .init(
                sessionIdentifier: sessionId,
                initialSessionData: sessionData
            ),
            configuration: configuration,
            apiClient: apiClient
        )
        
        // fetch and store checkout attempt id
        async let checkoutAttemptId = fetchCheckoutAttemptId(
            with: configuration,
            apiClient: apiClient
        )
        
        let checkout = try await Checkout(
            configuration: configuration,
            session: session,
            checkoutAttemptId: checkoutAttemptId,
            presentationDelegate: presentationDelegate
        )
        
        return checkout
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
        presentationDelegate: PresentationDelegate?
    ) async throws -> Checkout {
        let apiClient = APIClient(apiContext: configuration.context.apiContext)
        
        // fetch and store checkout attempt id
        let checkoutAttemptId = try await fetchCheckoutAttemptId(
            with: configuration,
            apiClient: apiClient
        )
        
        let checkout = Checkout(
            configuration: configuration,
            paymentMethods: paymentMethods,
            checkoutAttemptId: checkoutAttemptId,
            presentationDelegate: presentationDelegate
        )
        
        return checkout
    }
    
    // MARK: Internal
    
    internal func setupSession(
        with initialInfo: AdyenSession.InitialInfo,
        configuration: CheckoutConfiguration,
        apiClient: APIClientProtocol
    ) async throws -> AdyenSessionProtocol {
        try await AdyenSession.setup(
            with: initialInfo,
            apiClient: apiClient,
            context: configuration.context
        )
    }
    
    internal func fetchCheckoutAttemptId(
        with configuration: CheckoutConfiguration,
        apiClient: APIClientProtocol
    ) async throws -> String {
        ""
    }
}
