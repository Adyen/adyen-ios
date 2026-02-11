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
        async let checkoutAttemptId: String? = {
            guard let analyticsApiContext = configuration.analyticsApiContext else {
                return nil
            }
            return await checkoutAttemptIdProvider.fetchCheckoutAttemptId(
                with: analyticsApiContext
            )
        }()

        // TODO: Robert: Create the AdyenContext async. which in turn will create the analytics provider if checkoutAttemptId is available & the configuration flag is true.
        // TODO: Robert: for the public key fetching we do it async here at this point and pass it down to AdyenContext.

        let adyenContext = AdyenContext(
            apiContext: configuration.apiContext,
            payment: nil,
            amount: configuration.amount,
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
        async let checkoutAttemptId: String? = {
            guard let analyticsApiContext = configuration.analyticsApiContext else {
                return nil
            }
            return await checkoutAttemptIdProvider.fetchCheckoutAttemptId(
                with: analyticsApiContext
            )
        }()

        let adyenContext = AdyenContext(
            apiContext: configuration.apiContext,
            payment: nil,
            amount: configuration.amount,
            analyticsConfiguration: configuration.analyticsConfiguration
        )

        return await Checkout(
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
        async let checkoutAttemptId: String? = {
            guard let analyticsApiContext = configuration.analyticsApiContext else {
                return nil
            }
            return await checkoutAttemptIdProvider.fetchCheckoutAttemptId(
                with: analyticsApiContext
            )
        }()

        let adyenContext = AdyenContext(
            apiContext: configuration.apiContext,
            payment: nil,
            amount: configuration.amount,
            analyticsConfiguration: configuration.analyticsConfiguration
        )

        return await Checkout(
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
