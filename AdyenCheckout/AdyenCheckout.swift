//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenSession)
    @_spi(AdyenInternal) import AdyenSession
#endif
#if canImport(AdyenDropIn)
    @_spi(AdyenInternal) import AdyenDropIn
#endif
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif
import AdyenNetworking
import Foundation

/// `AdyenCheckout` is the entry point to the Checkout flow. You initialize it through its static methods for your chosen flow
/// and it prepares all the required data asynchronously and returns an `AdyenCheckout` instance ready to be used.
public final class AdyenCheckout: AdyenCheckoutProtocol {
    
    public let paymentMethods: PaymentMethods?
    internal let session: AdyenSessionProtocol?
    internal let checkoutAttemptId: String?
    internal let configuration: CheckoutConfiguration
    internal weak var presentationDelegate: PresentationDelegate?
    
    internal lazy var actionHandlingComponent: ActionHandlingComponent = {
        let handler = AdyenActionComponent(
            context: configuration.context,
            configuration: AdyenActionComponent.Configuration()
        )
        // TODO: create a way for CheckoutConfig to have AdyenActionComponent.Configuration
        // and it should provided if they want to have action handling
        // move AdyenActionComponent.Configuration to its own entity and make it public
        handler.delegate = self
        handler.presentationDelegate = presentationDelegate
        return handler
    }()
    
    // TODO: should we replace sessionId/sessionData params with a struct to future proof session init?
    /// Sets up the checkout object for the default flow
    /// with the values from your backend's `/session` call.
    /// - Parameters:
    ///   - sessionId: sessionId from the `/session` call response.
    ///   - sessionData: session data from the `/session` call response.
    ///   - configuration: The `CheckoutConfiguration` instance.
    ///   - presentationDelegate: A delegate in order to handle presentation logic if needed.
    ///   - completion: A closure that is called when the setup is complete, containing the checkout object.
    public static func setup(
        with sessionId: String,
        sessionData: String,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate? = nil
    ) async throws -> AdyenCheckout {
        try await setup(
            with: sessionId,
            sessionData: sessionData,
            configuration: configuration,
            presentationDelegate: presentationDelegate,
            provider: AdyenCheckoutProvider.default
        )
    }
    
    internal static func setup(
        with sessionId: String,
        sessionData: String,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate? = nil,
        provider: AdyenCheckoutProviding = AdyenCheckoutProvider.default
    ) async throws -> AdyenCheckout {
        try await provider.setup(
            with: sessionId,
            sessionData: sessionData,
            configuration: configuration,
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
    public static func setup(
        with paymentMethods: PaymentMethods,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate? = nil
    ) async throws -> AdyenCheckout {
        try await setup(
            with: paymentMethods,
            configuration: configuration,
            presentationDelegate: presentationDelegate,
            provider: AdyenCheckoutProvider.default
        )
    }
    
    internal static func setup(
        with paymentMethods: PaymentMethods,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate? = nil,
        provider: AdyenCheckoutProviding = AdyenCheckoutProvider.default
    ) async throws -> AdyenCheckout {
        try await provider.setup(
            with: paymentMethods,
            configuration: configuration,
            presentationDelegate: presentationDelegate
        )
    }
    
    public func createComponent(with paymentMethod: any PaymentMethod) -> AdyenCheckoutComponent? {
        // TODO: Add new v6 style here
        AdyenCheckoutComponent(
            paymentMethod: paymentMethod,
            configuration: configuration,
            delegate: self
        )
    }
    
    public func createComponent(with action: Action) -> AdyenCheckoutComponent? {
        AdyenCheckoutComponent(
            action: action,
            configuration: configuration,
            delegate: self
        )
    }
    
    public func createDropIn() -> DropInComponent? {
        // TODO: dropin creation discussion with new changes
        nil
    }
    
    // MARK: Internal

    internal init(
        configuration: CheckoutConfiguration,
        session: AdyenSessionProtocol? = nil,
        paymentMethods: PaymentMethods? = nil,
        checkoutAttemptId: String?,
        presentationDelegate: PresentationDelegate?
    ) {
        self.configuration = configuration
        self.session = session
        self.paymentMethods = paymentMethods ?? session?.state.paymentMethods
        self.checkoutAttemptId = checkoutAttemptId
        self.presentationDelegate = presentationDelegate
        
        self.session?.delegate = self
        self.session?.presentationDelegate = presentationDelegate
    }
}
