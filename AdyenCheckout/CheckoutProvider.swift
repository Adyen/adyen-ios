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
        
        let apiClient = APIClient(apiContext: configuration.apiContext)

        // fetch and store checkout attempt id
        let checkoutAttemptId: String? = await checkoutAttemptIdProvider.fetchCheckoutAttemptId(
            with: configuration.analyticsApiContext
        )

        // TODO: Robert: for the public key fetching we do it async here at this point and pass it down to AdyenContext.

        let adyenContext = AdyenContext(
            apiContext: configuration.apiContext,
            payment: nil,
            amount: configuration.amount,
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
            checkoutAttemptId: checkoutAttemptId,
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

        // fetch and store checkout attempt id
        let checkoutAttemptId: String? = await checkoutAttemptIdProvider.fetchCheckoutAttemptId(
            with: configuration.analyticsApiContext
        )

        let adyenContext = AdyenContext(
            apiContext: configuration.apiContext,
            payment: nil,
            amount: configuration.amount,
            checkoutAttemptId: checkoutAttemptId,
            analyticsAPIContext: configuration.analyticsApiContext,
            analyticsConfiguration: configuration.analyticsConfiguration
        )

        return Checkout(
            configuration: configuration,
            paymentMethods: paymentMethods,
            checkoutAttemptId: checkoutAttemptId,
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

        // fetch and store checkout attempt id
        // fetch and store checkout attempt id
        let checkoutAttemptId: String? = await checkoutAttemptIdProvider.fetchCheckoutAttemptId(
            with: configuration.analyticsApiContext
        )

        let adyenContext = AdyenContext(
            apiContext: configuration.apiContext,
            payment: nil,
            amount: configuration.amount,
            checkoutAttemptId: checkoutAttemptId,
            analyticsAPIContext: configuration.analyticsApiContext,
            analyticsConfiguration: configuration.analyticsConfiguration
        )

        return Checkout(
            configuration: configuration,
            checkoutAttemptId: checkoutAttemptId,
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
