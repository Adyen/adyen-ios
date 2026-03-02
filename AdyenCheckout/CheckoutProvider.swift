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
        
        let apiClient = APIClient(apiContext: configuration.apiContext)

        // fetch and store checkout attempt id
        let checkoutAttemptId: String? = await checkoutAttemptIdProvider.fetchCheckoutAttemptId(
            with: configuration.analyticsApiContext
        )

        async let publicKey = try await publicKeyProvider.fetchPublicKey(
            apiClient: apiClient,
            clientKey: configuration.apiContext.clientKey
        )

        let adyenContext = try await AdyenContext(
            apiContext: configuration.apiContext,
            payment: nil,
            amount: configuration.amount,
            publicKey: publicKey,
            checkoutAttemptId: checkoutAttemptId,
            analyticsAPIContext: configuration.analyticsApiContext,
            analyticsConfiguration: configuration.analyticsConfiguration
        )

        // create and store session and payment methods
        async let session = setupSession(
            with: sessionResponse,
            adyenContext: adyenContext,
            apiClient: apiClient
        )

        return try await Checkout(
            configuration: configuration,
            session: session,
            adyenContext: adyenContext,
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
            with: configuration.apiContext
        )

        let apiClient = APIClient(apiContext: configuration.apiContext)

        async let publicKey = try await publicKeyProvider.fetchPublicKey(
            apiClient: apiClient,
            clientKey: configuration.apiContext.clientKey
        )

        let adyenContext = try await AdyenContext(
            apiContext: configuration.apiContext,
            payment: nil,
            amount: configuration.amount,
            publicKey: publicKey,
            checkoutAttemptId: checkoutAttemptId,
            analyticsAPIContext: configuration.analyticsApiContext,
            analyticsConfiguration: configuration.analyticsConfiguration
        )

        return Checkout(
            configuration: configuration,
            paymentMethods: paymentMethods,
            adyenContext: adyenContext,
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
            with: configuration.apiContext
        )
        
        let apiClient = APIClient(apiContext: configuration.apiContext)

        async let publicKey = try await publicKeyProvider.fetchPublicKey(
            apiClient: apiClient,
            clientKey: configuration.apiContext.clientKey
        )

        let adyenContext = try await AdyenContext(
            apiContext: configuration.apiContext,
            payment: nil,
            amount: configuration.amount,
            publicKey: publicKey,
            checkoutAttemptId: checkoutAttemptId,
            analyticsAPIContext: configuration.analyticsApiContext,
            analyticsConfiguration: configuration.analyticsConfiguration
        )

        return Checkout(
            configuration: configuration,
            adyenContext: adyenContext,
            presentationDelegate: presentationDelegate
        )
    }
    
    // MARK: Internal
    
    internal func setupSession(
        with sessionResponse: SessionResponse,
        adyenContext: AdyenContext,
        apiClient: APIClientProtocol
    ) async throws -> SessionProtocol {
        try await Session.setup(
            with: sessionResponse,
            apiClient: apiClient,
            context: adyenContext
        )
    }
}
