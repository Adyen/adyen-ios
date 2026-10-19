//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenDropIn
import Testing

@MainActor
struct StoredPaymentMethodRemovalHandlerTests {

    @Test
    func handler_whenProviderSucceeds_shouldComplete() async throws {
        // Given
        let paymentMethod = try storedPaymentMethod()
        let handler: StoredPaymentMethodRemovalHandler = { _ in }

        // When
        try await handler(paymentMethod)
    }

    @Test
    func handler_whenProviderFails_shouldPropagateError() async throws {
        // Given
        let paymentMethod = try storedPaymentMethod()
        let handler: StoredPaymentMethodRemovalHandler = { _ in
            throw StoredPaymentMethodRemovalError.unsuccessful
        }

        // When
        do {
            try await handler(paymentMethod)
            Issue.record("Expected the removal handler to throw.")
        } catch let error as StoredPaymentMethodRemovalError {
            // Then
            #expect(error == .unsuccessful)
        }
    }

    @Test
    func removalError_whenProviderIsUnavailable_shouldBeExplicit() {
        // Given
        let error = StoredPaymentMethodRemovalError.unavailable

        // Then
        #expect(error == .unavailable)
    }

    private func storedPaymentMethod() throws -> StoredCardPaymentMethod {
        try AdyenCoder.decode(storedCreditCardDictionary) as StoredCardPaymentMethod
    }
}
