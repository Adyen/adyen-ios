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

/// Creates checkout cores with the context and callbacks for each flow.
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

    /// Sets up a checkout core using a `/sessions` response.
    /// - Parameters:
    ///   - sessionResponse: The response from the `/sessions` call.
    ///   - configuration: The checkout configuration.
    ///   - callbacks: The callbacks for this checkout flow.
    /// - Returns: A checkout core configured for the session.
    /// - Throws: `CheckoutError` if the configuration requires callbacks that are missing, or if context or session setup fails.
    internal func setup(
        with sessionResponse: SessionResponse,
        configuration: CheckoutConfiguration,
        callbacks: CheckoutCallbacks
    ) async throws -> CheckoutCoreProtocol {

        let additionalCallbacks = AdditionalCallbacksStore(callbacks.additionalCallbacks)
        try configuration.validate(additionalCallbacks: additionalCallbacks)

        let apiClient = APIClient(apiContext: configuration.apiContext)
        let adyenContext = try await setupAdyenContext(configuration: configuration, apiClient: apiClient)
        let session = try await setupSession(
            with: sessionResponse,
            adyenContext: adyenContext,
            apiClient: apiClient
        )
        adyenContext.amount = session.state.amount

        return await CheckoutCore(
            configuration: configuration,
            session: session,
            adyenContext: adyenContext,
            resultCallbacks: callbacks,
            callbackHandler: BeforeSubmitCallbackHandler(
                handler: SessionCallbackHandler(session: session),
                session: session,
                callbacks: callbacks
            ),
            additionalCallbacks: additionalCallbacks
        )
    }
    
    /// Sets up a checkout core for the advanced flow.
    /// - Parameters:
    ///   - paymentMethods: The payment methods from the `/paymentMethods` response.
    ///   - configuration: The checkout configuration.
    ///   - callbacks: The callbacks for this checkout flow.
    /// - Returns: A checkout core configured for the advanced flow.
    /// - Throws: `CheckoutError` if the configuration requires callbacks that are missing, or if context setup fails.
    internal func setup(
        with paymentMethods: PaymentMethods,
        configuration: CheckoutConfiguration,
        callbacks: AdvancedCheckoutCallbacks
    ) async throws -> CheckoutCoreProtocol {

        let additionalCallbacks = AdditionalCallbacksStore(callbacks.additionalCallbacks)
        try configuration.validate(additionalCallbacks: additionalCallbacks)

        let apiClient = APIClient(apiContext: configuration.apiContext)
        let adyenContext = try await setupAdyenContext(configuration: configuration, apiClient: apiClient)

        return await CheckoutCore(
            configuration: configuration,
            paymentMethods: paymentMethods,
            adyenContext: adyenContext,
            resultCallbacks: callbacks,
            callbackHandler: AdvancedCallbackHandler(callbacks: callbacks),
            additionalCallbacks: additionalCallbacks
        )
    }
    
    /// Sets up a checkout core for action handling only.
    /// - Parameters:
    ///   - configuration: The checkout configuration.
    ///   - callbacks: The callbacks for this checkout flow.
    /// - Returns: A checkout core configured for action handling.
    /// - Throws: `CheckoutError` if context setup fails.
    internal func setup(
        configuration: CheckoutConfiguration,
        callbacks: ActionOnlyCheckoutCallbacks
    ) async throws -> CheckoutCoreProtocol {

        let apiClient = APIClient(apiContext: configuration.apiContext)
        let adyenContext = try await setupAdyenContext(configuration: configuration, apiClient: apiClient)

        return await CheckoutCore(
            configuration: configuration,
            adyenContext: adyenContext,
            resultCallbacks: callbacks,
            callbackHandler: ActionOnlyCallbackHandler(callbacks: callbacks)
        )
    }
    
    // MARK: Internal
    
    internal func setupSession(
        with sessionResponse: SessionResponse,
        adyenContext: AdyenContext,
        apiClient: AsyncAPIClientProtocol
    ) async throws -> SessionProtocol {
        do {
            return try await Session.setup(
                with: sessionResponse,
                apiClient: apiClient,
                context: adyenContext
            )
        } catch {
            throw CheckoutError(error: error, fallback: .sessionSetupFailure)
        }
    }

    private func setupAdyenContext(
        configuration: CheckoutConfiguration,
        apiClient: APIClient
    ) async throws -> AdyenContext {
        do {
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
                amount: nil,
                publicKey: publicKey,
                checkoutAttemptId: checkoutAttemptId,
                analyticsAPIContext: configuration.analyticsApiContext,
                analyticsConfiguration: configuration.analyticsConfiguration
            )
        } catch {
            throw CheckoutError(error: error, fallback: .httpError)
        }
    }

}
