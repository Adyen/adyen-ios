//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenDropIn
import Testing
import UIKit

@MainActor
struct PaymentMethodListHeaderViewModelTests {

    @Test
    func init_shouldSetAmount() {
        // Given
        let expectedAmount = "€100.00"

        // When
        let sut = PaymentMethodListHeaderViewModel(
            title: expectedAmount,
            subtitle: "Test",
            applePayView: nil,
            theme: .init()
        )

        // Then
        #expect(sut.title == expectedAmount)
    }

    @Test
    func init_shouldSetSubtitle() {
        // Given
        let expectedSubtitle = "Select your payment method"

        // When
        let sut = PaymentMethodListHeaderViewModel(
            title: "€1.00",
            subtitle: expectedSubtitle,
            applePayView: nil,
            theme: .init()
        )

        // Then
        #expect(sut.subtitle == expectedSubtitle)
    }

    @Test
    func applePayView_givenNil_shouldBeNil() {
        // Given
        let sut = PaymentMethodListHeaderViewModel(
            title: "€1.00",
            subtitle: "Test",
            applePayView: nil,
            theme: .init()
        )

        // Then
        #expect(sut.applePayView == nil)
    }

    @Test
    func applePayView_givenView_shouldKeepSameInstance() {
        // Given
        let applePayView = UIView()

        // When
        let sut = PaymentMethodListHeaderViewModel(
            title: "€1.00",
            subtitle: "Test",
            applePayView: applePayView,
            theme: .init()
        )

        // Then
        #expect(sut.applePayView === applePayView)
    }
}
