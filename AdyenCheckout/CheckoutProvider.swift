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

        let analyticsApiClient = configuration.analyticsApiContext.flatMap { APIClient(apiContext: $0) }
        // TODO: Improvement: Suggestion: instead of the checkout provider being aware of something as specific as checkoutAttemptId.
        // - This could be wrapped in something related to Analytics ex: await AnalyticsProvider.init() and internally fetch what is required for analytics.
        // - At this point, without much context we may ask the question `what is the checkoutAttemptId?`. Alternatively -
        // - If we read something like `await AnalyticsProvider.init()` then we know that analytics is being setup and internally this attemptId is being fetched.
        let checkoutAttemptId: String? = await checkoutAttemptIdProvider.fetchCheckoutAttemptId(
            with: analyticsApiClient
        )

        // TODO: Improvement: Suggestion: Instead of fetching the publicKey, which requires a bit of searching to understand that it is being used for encryption ex: card encryption.
        // if there is a holding type like `await Encryptor.init(clientId:)` then we know that the Encryption is being setup and  key is being used for encryption and it is mapped to the clientId.
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
        let analyticsApiClient = configuration.analyticsApiContext.flatMap { APIClient(apiContext: $0) }

        async let checkoutAttemptId = checkoutAttemptIdProvider.fetchCheckoutAttemptId(
            with: analyticsApiClient
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
        let analyticsApiClient = configuration.analyticsApiContext.flatMap { APIClient(apiContext: $0) }

        async let checkoutAttemptId = checkoutAttemptIdProvider.fetchCheckoutAttemptId(
            with: analyticsApiClient
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
