//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenSession)
    import AdyenSession
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
        callbackStore: SessionCheckoutCallbackStore,
        presentationDelegate: PresentationDelegate?
    ) async throws -> CheckoutCoreProtocol {

        let apiClient = APIClient(apiContext: configuration.apiContext)
        let adyenContext = try await setupAdyenContext(configuration: configuration, apiClient: apiClient)
        let session = try await setupSession(
            with: sessionResponse,
            adyenContext: adyenContext,
            apiClient: apiClient
        )

        return await CheckoutCore(
            configuration: configuration,
            session: session,
            adyenContext: adyenContext,
            presentationDelegate: presentationDelegate,
            resultCallbacks: callbackStore,
            callbackHandler: BeforeSubmitCallbackHandler(
                inner: SessionCallbackHandler(session: session),
                session: session,
                callbackStore: callbackStore
            )
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
        callbackStore: AdvancedCheckoutCallbackStore,
        presentationDelegate: PresentationDelegate?
    ) async throws -> CheckoutCoreProtocol {

        let apiClient = APIClient(apiContext: configuration.apiContext)
        let adyenContext = try await setupAdyenContext(configuration: configuration, apiClient: apiClient)

        return await CheckoutCore(
            configuration: configuration,
            paymentMethods: paymentMethods,
            adyenContext: adyenContext,
            presentationDelegate: presentationDelegate,
            resultCallbacks: callbackStore,
            callbackHandler: AdvancedCallbackHandler(callbackStore: callbackStore)
        )
    }
    
    /// Sets up the checkout object for action handling only.
    /// - Parameters:
    ///   - configuration: The `CheckoutConfiguration` instance.
    ///   - presentationDelegate: A delegate for handling action UI presentation.
    internal func setup(
        configuration: CheckoutConfiguration,
        callbackStore: ActionOnlyCheckoutCallbackStore,
        presentationDelegate: PresentationDelegate?
    ) async throws -> CheckoutCoreProtocol {

        let apiClient = APIClient(apiContext: configuration.apiContext)
        let adyenContext = try await setupAdyenContext(configuration: configuration, apiClient: apiClient)

        return await CheckoutCore(
            configuration: configuration,
            adyenContext: adyenContext,
            presentationDelegate: presentationDelegate,
            resultCallbacks: callbackStore,
            callbackHandler: ActionOnlyCallbackHandler(callbackStore: callbackStore)
        )
    }
    
    // MARK: Internal
    
    internal func setupSession(
        with sessionResponse: SessionResponse,
        adyenContext: AdyenContext,
        apiClient: AsyncAPIClientProtocol
    ) async throws -> SessionProtocol {
        try await Session.setup(
            with: sessionResponse,
            apiClient: apiClient,
            context: adyenContext
        )
    }

    private func setupAdyenContext(
        configuration: CheckoutConfiguration,
        apiClient: APIClient
    ) async throws -> AdyenContext {

        let analyticsApiClient = configuration.analyticsApiContext.flatMap { APIClient(apiContext: $0) }

        // TODO: Improvement: Suggestion: instead of the checkout provider being aware of something as specific as checkoutAttemptId.
        // - This could be wrapped in something related to Analytics ex: await AnalyticsProvider.init()
        //   and internally fetch what is required for analytics.
        async let checkoutAttemptId = checkoutAttemptIdProvider.fetchCheckoutAttemptId(
            with: analyticsApiClient
        )

        // TODO: Improvement: Suggestion: instead of fetching the publicKey, which requires a bit of searching to understand
        // that it is being used for encryption ex: card encryption.
        // If there is a holding type like `await Encryptor.init(clientId:)` then we know that the Encryption is being setup
        // and key is being used for encryption and it is mapped to the clientId.
        async let publicKey = try await publicKeyProvider.fetchPublicKey(
            apiClient: apiClient,
            clientKey: configuration.apiContext.clientKey
        )

        return try await AdyenContext(
            apiContext: configuration.apiContext,
            amount: configuration.amount,
            publicKey: publicKey,
            checkoutAttemptId: checkoutAttemptId,
            analyticsAPIContext: configuration.analyticsApiContext,
            analyticsConfiguration: configuration.analyticsConfiguration
        )

    }
}
