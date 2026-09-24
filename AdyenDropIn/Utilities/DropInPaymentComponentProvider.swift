//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

/// Tells Drop-in which payment methods can be shown and builds their components.
///
/// Availability is a side-effect-free snapshot used for the payment method list.
/// Building is the authoritative step and re-checks any prerequisites itself.
@MainActor
package struct DropInPaymentComponentProvider {

    private let availability: @MainActor (_ paymentMethod: PaymentMethod) -> Bool
    private let builder: @MainActor (_ paymentMethod: PaymentMethod) throws -> PaymentComponent

    /// Creates a provider.
    ///
    /// - Parameters:
    ///   - isAvailable: Returns whether a component can currently be built for a payment method.
    ///   - build: Builds a fresh component for a payment method.
    package init(
        isAvailable: @escaping @MainActor (_ paymentMethod: PaymentMethod) -> Bool,
        build: @escaping @MainActor (_ paymentMethod: PaymentMethod) throws -> PaymentComponent
    ) {
        self.availability = isAvailable
        self.builder = build
    }

    package func isAvailable(for paymentMethod: PaymentMethod) -> Bool {
        availability(paymentMethod)
    }

    package func buildComponent(for paymentMethod: PaymentMethod) throws -> PaymentComponent {
        try builder(paymentMethod)
    }
}
