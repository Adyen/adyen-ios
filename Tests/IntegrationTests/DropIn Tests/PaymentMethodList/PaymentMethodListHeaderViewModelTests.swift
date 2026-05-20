//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenDropIn
import Testing

@MainActor
struct PaymentMethodListHeaderViewModelTests {

    @Test
    func init_shouldSetAmount() {
        // Given
        let expectedAmount = "€100.00"

        // When
        let sut = PaymentMethodListHeaderViewModel(
            amount: expectedAmount,
            subtitle: "Test",
            applePayButtonState: .hidden,
            theme: .init()
        )

        // Then
        #expect(sut.amount == expectedAmount)
    }

    @Test
    func init_shouldSetSubtitle() {
        // Given
        let expectedSubtitle = "Select your payment method"

        // When
        let sut = PaymentMethodListHeaderViewModel(
            amount: "€1.00",
            subtitle: expectedSubtitle,
            applePayButtonState: .hidden,
            theme: .init()
        )

        // Then
        #expect(sut.subtitle == expectedSubtitle)
    }

    @Test
    func applePayButtonState_givenHidden_shouldBeHidden() {
        // Given
        let sut = PaymentMethodListHeaderViewModel(
            amount: "€1.00",
            subtitle: "Test",
            applePayButtonState: .hidden,
            theme: .init()
        )

        // Then
        if case .hidden = sut.applePayButtonState {
            // Success
        } else {
            Issue.record("Expected applePayButtonState to be .hidden")
        }
    }

    @Test
    func applePayButtonState_givenVisible_shouldCallOnTapHandler() {
        // Given
        var tapCount = 0
        let sut = PaymentMethodListHeaderViewModel(
            amount: "€1.00",
            subtitle: "Test",
            applePayButtonState: .visible(onTap: { tapCount += 1 }),
            theme: .init()
        )

        // When
        if case let .visible(onTap) = sut.applePayButtonState {
            onTap()
            onTap()
        }

        // Then
        #expect(tapCount == 2)
    }
}
