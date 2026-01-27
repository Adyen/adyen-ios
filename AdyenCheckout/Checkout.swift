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

/// The entry point for the Adyen Checkout SDK.
///
/// Use `Checkout` to create payment components and handle actions.
/// Initialize using one of the static `setup` methods.
///
/// ## Session Flow
/// ```swift
/// let checkout = try await Checkout.setup(
///     with: sessionId,
///     sessionData: sessionData,
///     configuration: config
/// )
/// ```
///
/// ## Advanced Flow
/// ```swift
/// let checkout = try await Checkout.setup(
///     with: paymentMethods,
///     configuration: config
/// )
/// ```
///
/// ## Creating Components
/// ```swift
/// let component = checkout.createPaymentComponent(for: .scheme)
/// ```
public final class Checkout: CheckoutProtocol {
    
    /// The available payment methods for this checkout session.
    public let paymentMethods: PaymentMethods?
    internal let session: SessionProtocol?
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
    
    // MARK: - Public
    
    /// Sets up checkout for the session flow.
    ///
    /// Use this method when integrating with the `/sessions` endpoint.
    ///
    /// - Parameters:
    ///   - sessionResponse: The response from the `/sessions` call.
    ///   - configuration: The checkout configuration.
    ///   - presentationDelegate: Optional delegate for handling UI presentation.
    /// - Returns: A `Checkout` instance.
    /// - Throws: An error if setup fails.
    public static func setup(
        with sessionResponse: SessionResponse,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate? = nil
    ) async throws -> Checkout {
        try await setup(
            with: sessionResponse,
            configuration: configuration,
            presentationDelegate: presentationDelegate,
            provider: CheckoutProvider.default
        )
    }
    
    /// Sets up checkout for the advanced flow.
    ///
    /// Use this method when you handle `/payments` and `/payments/details` calls yourself.
    ///
    /// - Parameters:
    ///   - paymentMethods: The payment methods from the `/paymentMethods` response.
    ///   - configuration: The checkout configuration.
    ///   - presentationDelegate: Optional delegate for handling UI presentation.
    /// - Returns: A `Checkout` instance.
    /// - Throws: An error if setup fails.
    public static func setup(
        with paymentMethods: PaymentMethods,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate? = nil
    ) async throws -> Checkout {
        try await setup(
            with: paymentMethods,
            configuration: configuration,
            presentationDelegate: presentationDelegate,
            provider: CheckoutProvider.default
        )
    }

    // MARK: Internal

    internal init(
        configuration: CheckoutConfiguration,
        session: SessionProtocol? = nil,
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

public extension Checkout {

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
    func createPaymentComponent(for type: PaymentMethodType) -> CheckoutPaymentComponent? {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: type) else { return nil }
        
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
    func createPaymentComponent(for identifier: String) -> CheckoutPaymentComponent? {
        guard let storedPaymentMethod = paymentMethods?.stored.first(where: { $0.identifier == identifier }) else { return nil }
        
        return CheckoutPaymentComponent(
            storedPaymentMethod: storedPaymentMethod,
            configuration: configuration,
            delegate: self
        )
    }

    /// Creates a Drop-in component with all available payment methods.
    ///
    /// - Returns: A configured Drop-in component, or `nil` if unavailable.
    func createDropIn() -> DropInComponent? {
        // TODO: dropin creation discussion with new changes
        nil
    }

    /// Handles an action received from the `/payments` or `/payments/details` response.
    ///
    /// Some actions require showing UI (e.g., 3DS challenges, vouchers, QR codes).
    /// The `presentationDelegate` provided on setup is used to handle such cases.
    ///
    /// - Parameter action: The action to handle.
    func handle(action: Action) {
        actionHandlingComponent.handle(action)
    }
}

internal extension Checkout {

    static func setup(
        with sessionResponse: SessionResponse,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate? = nil,
        provider: CheckoutProviding = CheckoutProvider.default
    ) async throws -> Checkout {
        try await provider.setup(
            with: sessionResponse,
            configuration: configuration,
            presentationDelegate: presentationDelegate
        )
    }

    static func setup(
        with paymentMethods: PaymentMethods,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate? = nil,
        provider: CheckoutProviding = CheckoutProvider.default
    ) async throws -> Checkout {
        try await provider.setup(
            with: paymentMethods,
            configuration: configuration,
            presentationDelegate: presentationDelegate
        )
    }
}
