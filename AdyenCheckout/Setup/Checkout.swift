//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenSession)
    import AdyenSession
#endif
import Foundation

/// The entry point for setting up an Adyen Checkout flow.
@MainActor
public enum Checkout {

    /// Sets up checkout for the session flow.
    /// - Parameters:
    ///   - sessionResponse: The response from the `/sessions` call.
    ///   - configuration: The checkout configuration.
    ///   - presentationDelegate: Optional delegate for handling UI presentation.
    /// - Returns: A session checkout instance exposing session-compatible APIs.
    /// - Throws: ``CheckoutError`` if the checkout session cannot be established.
    ///   Inspect ``CheckoutError/code`` for the specific failure reason.
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
    /// - Throws: ``CheckoutError`` if checkout setup fails. Inspect ``CheckoutError/code`` for the specific failure reason.
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
    /// - Throws: ``CheckoutError`` if checkout setup fails. Inspect ``CheckoutError/code`` for the specific failure reason.
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

    /// Passes a URL to the SDK to resume an active redirect action after the shopper returns from a browser or external app.
    ///
    /// Call this from every entry point where your app receives incoming URLs:
    ///
    /// **UIKit - AppDelegate:**
    /// ```swift
    /// func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    ///     Checkout.handleReturn(url: url)
    ///     return true
    /// }
    /// ```
    ///
    /// **UIKit - SceneDelegate:**
    /// ```swift
    /// func scene(_ scene: UIScene, openURLContexts contexts: Set<UIOpenURLContext>) {
    ///     guard let url = contexts.first?.url else { return }
    ///     Checkout.handleReturn(url: url)
    /// }
    /// ```
    ///
    /// **SwiftUI:**
    /// ```swift
    /// ContentView()
    ///     .onOpenURL { url in Checkout.handleReturn(url: url) }
    /// ```
    ///
    /// It is safe to pass all incoming URLs; any URL not belonging to an active checkout redirect is ignored.
    ///
    /// - Parameter url: The URL received when the shopper returns to the app.
    /// - Returns: `true` if the URL was handled by an active checkout redirect; `false` otherwise.
    @discardableResult
    public static func handleReturn(url: URL) -> Bool {
        RedirectComponent.applicationDidOpen(from: url)
    }
}

internal extension Checkout {

    static func setup(
        with sessionResponse: SessionResponse,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate? = nil,
        provider: CheckoutProviding
    ) async throws -> SessionCheckout {
        let callbackStore = SessionCheckoutCallbackStore()
        let core = try await setup(
            with: sessionResponse,
            configuration: configuration,
            callbackStore: callbackStore,
            presentationDelegate: presentationDelegate,
            provider: provider
        )
        return SessionCheckout(core: core, callbackStore: callbackStore)
    }

    static func setup(
        with paymentMethods: PaymentMethods,
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate? = nil,
        provider: CheckoutProviding
    ) async throws -> AdvancedCheckout {
        let callbackStore = AdvancedCheckoutCallbackStore()
        let core = try await setup(
            with: paymentMethods,
            configuration: configuration,
            callbackStore: callbackStore,
            presentationDelegate: presentationDelegate,
            provider: provider
        )
        return AdvancedCheckout(core: core, callbackStore: callbackStore)
    }

    static func setup(
        configuration: CheckoutConfiguration,
        presentationDelegate: PresentationDelegate? = nil,
        provider: CheckoutProviding
    ) async throws -> ActionOnlyCheckout {
        let callbackStore = ActionOnlyCheckoutCallbackStore()
        let core = try await setup(
            configuration: configuration,
            callbackStore: callbackStore,
            presentationDelegate: presentationDelegate,
            provider: provider
        )
        return ActionOnlyCheckout(core: core, callbackStore: callbackStore)
    }

    static func setup(
        with sessionResponse: SessionResponse,
        configuration: CheckoutConfiguration,
        callbackStore: SessionCheckoutCallbackStore,
        presentationDelegate: PresentationDelegate? = nil,
        provider: CheckoutProviding = CheckoutProvider.default
    ) async throws -> CheckoutCoreProtocol {
        try await provider.setup(
            with: sessionResponse,
            configuration: configuration,
            callbackStore: callbackStore,
            presentationDelegate: presentationDelegate
        )
    }

    static func setup(
        with paymentMethods: PaymentMethods,
        configuration: CheckoutConfiguration,
        callbackStore: AdvancedCheckoutCallbackStore,
        presentationDelegate: PresentationDelegate? = nil,
        provider: CheckoutProviding = CheckoutProvider.default
    ) async throws -> CheckoutCoreProtocol {
        try await provider.setup(
            with: paymentMethods,
            configuration: configuration,
            callbackStore: callbackStore,
            presentationDelegate: presentationDelegate
        )
    }

    static func setup(
        configuration: CheckoutConfiguration,
        callbackStore: ActionOnlyCheckoutCallbackStore,
        presentationDelegate: PresentationDelegate? = nil,
        provider: CheckoutProviding = CheckoutProvider.default
    ) async throws -> CheckoutCoreProtocol {
        try await provider.setup(
            configuration: configuration,
            callbackStore: callbackStore,
            presentationDelegate: presentationDelegate
        )
    }
}
