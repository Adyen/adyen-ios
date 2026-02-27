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

    private let publicKeyProvider: PublicKeyFetching

    internal init(
        checkoutAttemptIdProvider: CheckoutAttemptIdProviding = CheckoutAttemptIdProvider(),
        publicKeyProvider: PublicKeyFetching = PublicKeyFetcher()
    ) {
        self.checkoutAttemptIdProvider = checkoutAttemptIdProvider
        self.publicKeyProvider = publicKeyProvider
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

        // TODO: Robert: Note here we are using try? do we already want to fail here if in the 0.0001% of the change that there is a failure. (I assume yes?)
        async let publicKey = try await publicKeyProvider.fetchPublicKey(
            apiClient: apiClient,
            clientKey: configuration.context.apiContext.clientKey
        )

        // TODO: Robert: Create the AdyenContext async. which in turn will create the analytics provider if checkoutAttemptId is available & the configuration flag is true.

        return try await Checkout(
            configuration: configuration,
            session: session,
            checkoutAttemptId: checkoutAttemptId,
            publicKey: publicKey,
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

        async let checkoutAttemptId = checkoutAttemptIdProvider.fetchCheckoutAttemptId(
            with: configuration
        )

        let apiClient = APIClient(apiContext: configuration.context.apiContext)

        async let publicKey = try await publicKeyProvider.fetchPublicKey(
            apiClient: apiClient,
            clientKey: configuration.context.apiContext.clientKey
        )

        return try await Checkout(
            configuration: configuration,
            paymentMethods: paymentMethods,
            checkoutAttemptId: checkoutAttemptId,
            publicKey: publicKey,
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

        async let checkoutAttemptId = checkoutAttemptIdProvider.fetchCheckoutAttemptId(
            with: configuration
        )
        
        let apiClient = APIClient(apiContext: configuration.context.apiContext)

        async let publicKey = try await publicKeyProvider.fetchPublicKey(
            apiClient: apiClient,
            clientKey: configuration.context.apiContext.clientKey
        )

        return try await Checkout(
            configuration: configuration,
            checkoutAttemptId: checkoutAttemptId,
            publicKey: publicKey,
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
