//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenActions)
    import AdyenActions
#endif
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
    ///   - callbacks: The callbacks for this checkout flow.
    /// - Returns: A checkout instance that can create payment components and Drop-in.
    /// - Throws: ``CheckoutError`` if the checkout session cannot be established.
    ///   Inspect ``CheckoutError/code`` for the specific failure reason.
    public static func setup(
        with sessionResponse: SessionResponse,
        configuration: CheckoutConfiguration,
        callbacks: CheckoutCallbacks
    ) async throws -> PaymentCheckout {
        try await setup(
            with: sessionResponse,
            configuration: configuration,
            callbacks: callbacks,
            provider: CheckoutProvider.default
        )
    }

    /// Sets up checkout for the advanced flow.
    /// - Parameters:
    ///   - paymentMethods: The payment methods from the `/paymentMethods` response.
    ///   - configuration: The checkout configuration.
    ///   - callbacks: The callbacks for this checkout flow.
    /// - Returns: A checkout instance that can create payment components and Drop-in.
    /// - Throws: ``CheckoutError`` if checkout setup fails. Inspect ``CheckoutError/code`` for the specific failure reason.
    package static func setup(
        with paymentMethods: PaymentMethods,
        configuration: CheckoutConfiguration,
        callbacks: AdvancedCheckoutCallbacks
    ) async throws -> PaymentCheckout {
        try await setup(
            with: paymentMethods,
            configuration: configuration,
            callbacks: callbacks,
            provider: CheckoutProvider.default
        )
    }

    /// Sets up checkout for action handling only.
    /// - Parameters:
    ///   - configuration: The checkout configuration.
    ///   - callbacks: The callbacks for this checkout flow.
    /// - Returns: An action-only checkout instance exposing action handling APIs.
    /// - Throws: ``CheckoutError`` if checkout setup fails. Inspect ``CheckoutError/code`` for the specific failure reason.
    public static func setup(
        configuration: CheckoutConfiguration,
        callbacks: ActionOnlyCheckoutCallbacks
    ) async throws -> ActionOnlyCheckout {
        try await setup(
            configuration: configuration,
            callbacks: callbacks,
            provider: CheckoutProvider.default
        )
    }

    #if canImport(AdyenActions)
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
    #endif
}

internal extension Checkout {

    static func setup(
        with sessionResponse: SessionResponse,
        configuration: CheckoutConfiguration,
        callbacks: CheckoutCallbacks,
        provider: CheckoutProviding
    ) async throws -> PaymentCheckout {
        let core = try await provider.setup(
            with: sessionResponse,
            configuration: configuration,
            callbacks: callbacks
        )
        return PaymentCheckout(core: core)
    }

    static func setup(
        with paymentMethods: PaymentMethods,
        configuration: CheckoutConfiguration,
        callbacks: AdvancedCheckoutCallbacks,
        provider: CheckoutProviding
    ) async throws -> PaymentCheckout {
        let core = try await provider.setup(
            with: paymentMethods,
            configuration: configuration,
            callbacks: callbacks
        )
        return PaymentCheckout(core: core)
    }

    static func setup(
        configuration: CheckoutConfiguration,
        callbacks: ActionOnlyCheckoutCallbacks,
        provider: CheckoutProviding
    ) async throws -> ActionOnlyCheckout {
        let core = try await provider.setup(
            configuration: configuration,
            callbacks: callbacks
        )
        return ActionOnlyCheckout(core: core)
    }
}
