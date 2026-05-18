//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenSession)
    import AdyenSession
#endif

/// The entry point for setting up an Adyen Checkout flow.
@MainActor
public enum Checkout {

    /// Sets up checkout for the session flow.
    /// - Parameters:
    ///   - sessionResponse: The response from the `/sessions` call.
    ///   - configuration: The checkout configuration.
    ///   - presentationDelegate: Optional delegate for handling UI presentation.
    /// - Returns: A session checkout instance exposing session-compatible APIs.
    public static func setup(
        with sessionResponse: SessionResponse,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate? = nil
    ) async throws -> SessionCheckout {
        try await setup(
            with: sessionResponse,
            configuration: configuration,
            presentationDelegate: presentationDelegate,
            provider: CheckoutProvider.default
        )
    }

    /// Sets up checkout for the advanced flow.
    /// - Parameters:
    ///   - paymentMethods: The payment methods from the `/paymentMethods` response.
    ///   - configuration: The checkout configuration.
    ///   - presentationDelegate: Optional delegate for handling UI presentation.
    /// - Returns: An advanced checkout instance exposing advanced-flow APIs.
    public static func setup(
        with paymentMethods: PaymentMethods,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate? = nil
    ) async throws -> AdvancedCheckout {
        try await setup(
            with: paymentMethods,
            configuration: configuration,
            presentationDelegate: presentationDelegate,
            provider: CheckoutProvider.default
        )
    }

    /// Sets up checkout for action handling only.
    /// - Parameters:
    ///   - configuration: The checkout configuration.
    ///   - presentationDelegate: Optional delegate for handling UI presentation.
    /// - Returns: An action-only checkout instance exposing action handling APIs.
    public static func setup(
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate? = nil
    ) async throws -> ActionOnlyCheckout {
        try await setup(
            configuration: configuration,
            presentationDelegate: presentationDelegate,
            provider: CheckoutProvider.default
        )
    }
}

internal extension Checkout {

    static func setup(
        with sessionResponse: SessionResponse,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate? = nil,
        provider: CheckoutProviding
    ) async throws -> SessionCheckout {
        let callbacks = SessionCheckoutCallbacks()
        let core = try await setup(
            with: sessionResponse,
            configuration: configuration,
            callbacks: callbacks,
            presentationDelegate: presentationDelegate,
            provider: provider
        )
        return SessionCheckout(core: core, callbacks: callbacks)
    }

    static func setup(
        with paymentMethods: PaymentMethods,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate? = nil,
        provider: CheckoutProviding
    ) async throws -> AdvancedCheckout {
        let callbacks = AdvancedCheckoutCallbacks()
        let core = try await setup(
            with: paymentMethods,
            configuration: configuration,
            callbacks: callbacks,
            presentationDelegate: presentationDelegate,
            provider: provider
        )
        return AdvancedCheckout(core: core, callbacks: callbacks)
    }

    static func setup(
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate? = nil,
        provider: CheckoutProviding
    ) async throws -> ActionOnlyCheckout {
        let callbacks = ActionOnlyCheckoutCallbacks()
        let core = try await setup(
            configuration: configuration,
            callbacks: callbacks,
            presentationDelegate: presentationDelegate,
            provider: provider
        )
        return ActionOnlyCheckout(core: core, callbacks: callbacks)
    }

    static func setup(
        with sessionResponse: SessionResponse,
        configuration: CheckoutConfiguration,
        callbacks: SessionCheckoutCallbacks,
        presentationDelegate: PresentationDelegate? = nil,
        provider: CheckoutProviding = CheckoutProvider.default
    ) async throws -> CheckoutCoreProtocol {
        try await provider.setup(
            with: sessionResponse,
            configuration: configuration,
            callbacks: callbacks,
            presentationDelegate: presentationDelegate
        )
    }

    static func setup(
        with paymentMethods: PaymentMethods,
        configuration: CheckoutConfiguration,
        callbacks: AdvancedCheckoutCallbacks,
        presentationDelegate: PresentationDelegate? = nil,
        provider: CheckoutProviding = CheckoutProvider.default
    ) async throws -> CheckoutCoreProtocol {
        try await provider.setup(
            with: paymentMethods,
            configuration: configuration,
            callbacks: callbacks,
            presentationDelegate: presentationDelegate
        )
    }

    static func setup(
        configuration: CheckoutConfiguration,
        callbacks: ActionOnlyCheckoutCallbacks,
        presentationDelegate: PresentationDelegate? = nil,
        provider: CheckoutProviding = CheckoutProvider.default
    ) async throws -> CheckoutCoreProtocol {
        try await provider.setup(
            configuration: configuration,
            callbacks: callbacks,
            presentationDelegate: presentationDelegate
        )
    }
}
