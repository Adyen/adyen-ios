//
// Copyright (c) Adyen N.V.
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
        let handler = CheckoutActionComponent(
            context: configuration.context,
            configuration: CheckoutActionComponent.Configuration()
        )
        // TODO: create a way for CheckoutConfig to have CheckoutActionComponent.Configuration
        // and it should provided if they want to have action handling
        // move CheckoutActionComponent.Configuration to its own entity and make it public
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
    
    /// Creates a payment component for the specified payment method type.
    ///
    /// Use this method to create a component for regular (non-stored) payment methods.
    ///
    /// - Parameter type: The type of payment method to create a component for (e.g., `.scheme` for cards, `.ideal` for iDEAL).
    /// - Returns: A configured payment component, or `nil` if the payment method is not available
    ///   in the current payment methods.
    ///
    /// ## Example
    /// ```swift
    /// if let cardComponent = checkout.createPaymentComponent(for: .scheme) {
    ///     present(cardComponent.viewController, animated: true)
    /// }
    /// ```
    public func createPaymentComponent(for type: PaymentMethodType) -> CheckoutPaymentComponent? {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: type) else { return nil }
        
        // TODO: Add new v6 style here
        return CheckoutPaymentComponent(
            paymentMethod: paymentMethod,
            configuration: configuration,
            delegate: self
        )
    }
    
    /// Creates a payment component for a stored payment method.
    ///
    /// Use this method to create a component for previously saved payment methods,
    /// such as stored cards or saved bank accounts. The identifier uniquely identifies
    /// the stored payment method from the shopper's saved payment methods.
    ///
    /// - Parameter identifier: The unique identifier of the stored payment method.
    ///   This value comes from `paymentMethods.stored`.
    /// - Returns: A configured payment component, or `nil` if no stored payment method
    ///   with the given identifier exists.
    ///
    /// ## Example
    /// ```swift
    ///
    /// // Create component for selected stored method
    /// if let storedComponent = checkout.createPaymentComponent(for: selectedMethod.identifier) {
    ///     present(storedComponent.viewController, animated: true)
    /// }
    /// ```
    public func createPaymentComponent(for identifier: String) -> CheckoutPaymentComponent? {
        guard let storedPaymentMethod = paymentMethods?.stored.first(where: { $0.identifier == identifier }) else { return nil }
        
        // TODO: Add new v6 style here
        return CheckoutPaymentComponent(
            storedPaymentMethod: storedPaymentMethod,
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
