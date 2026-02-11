//
// Copyright (c) 2025 Adyen N.V.
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
    
    private let checkoutAttemptIdProvider: CheckoutAttemptIdProviding

    internal init(checkoutAttemptIdProvider: CheckoutAttemptIdProviding = CheckoutAttemptIdProvider()) {
        self.checkoutAttemptIdProvider = checkoutAttemptIdProvider
    }
    
    internal static let `default` = CheckoutProvider()
    
    internal func setup(
        with sessionResponse: SessionResponse,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate?
    ) async throws -> Checkout {
        
        let apiClient = APIClient(apiContext: configuration.context.apiContext)
        
        // create and store session and payment methods
        async let session = setupSession(
            with: sessionResponse,
            configuration: configuration,
            apiClient: apiClient
        )
        
        // fetch and store checkout attempt id
        async let checkoutAttemptId = checkoutAttemptIdProvider.fetchCheckoutAttemptId(
            with: configuration
        )

        // TODO: Robert: Create the AdyenContext async. which in turn will create the analytics provider if checkoutAttemptId is available & the configuration flag is true.
        // TODO: Robert: for the public key fetching we do it async here at this point and pass it down to AdyenContext.

        return try await Checkout(
            configuration: configuration,
            session: session,
            checkoutAttemptId: checkoutAttemptId,
            presentationDelegate: presentationDelegate
        )
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

        let checkoutAttemptId = await checkoutAttemptIdProvider.fetchCheckoutAttemptId(
            with: configuration
        )
        
        return Checkout(
            configuration: configuration,
            paymentMethods: paymentMethods,
            checkoutAttemptId: checkoutAttemptId,
            presentationDelegate: presentationDelegate
        )
    }
    
    /// Sets up the checkout object for action handling only.
    /// - Parameters:
    ///   - configuration: The `CheckoutConfiguration` instance.
    ///   - presentationDelegate: A delegate for handling action UI presentation.
    internal func setup(
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate?
    ) async throws -> Checkout {

        let checkoutAttemptId = await checkoutAttemptIdProvider.fetchCheckoutAttemptId(
            with: configuration
        )
        
        return Checkout(
            configuration: configuration,
            checkoutAttemptId: checkoutAttemptId,
            presentationDelegate: presentationDelegate
        )
    }
    
    // MARK: Internal
    
    internal func setupSession(
        with sessionResponse: SessionResponse,
        configuration: CheckoutConfiguration,
        apiClient: APIClientProtocol
    ) async throws -> SessionProtocol {
        try await Session.setup(
            with: sessionResponse,
            apiClient: apiClient,
            context: configuration.context
        )
    }

}
