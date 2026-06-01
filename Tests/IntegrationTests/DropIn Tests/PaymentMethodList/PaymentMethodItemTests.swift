//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenDropIn
import Testing

@MainActor
struct PaymentMethodItemTests {

    @Test
    func init_shouldSetTitle() {
        // Given
        let expectedTitle = "Credit Card"
        let logoURLProvider = LogoURLProvider(environment: Dummy.apiContext.environment)

        // When
        let sut = PaymentMethodItem(
            title: expectedTitle,
            logoURLProvider: logoURLProvider,
            theme: .init()
        )

        // Then
        #expect(sut.title == expectedTitle)
    }

    @Test
    func init_shouldSetSubtitle() {
        // Given
        let expectedSubtitle = "Visa ending in 1234"
        let logoURLProvider = LogoURLProvider(environment: Dummy.apiContext.environment)

        // When
        let sut = PaymentMethodItem(
            title: "Card",
            subtitle: expectedSubtitle,
            logoURLProvider: logoURLProvider,
            theme: .init()
        )

        // Then
        #expect(sut.subtitle == expectedSubtitle)
    }

    @Test
    func init_shouldGenerateUniqueId() {
        // Given
        let logoURLProvider = LogoURLProvider(environment: Dummy.apiContext.environment)

        // When
        let sut1 = PaymentMethodItem(title: "Card", logoURLProvider: logoURLProvider, theme: .init())
        let sut2 = PaymentMethodItem(title: "Card", logoURLProvider: logoURLProvider, theme: .init())

        // Then
        #expect(sut1.id != sut2.id)
    }

    @Test
    func accessibilityLabel_givenCustomLabel_shouldUseCustomLabel() {
        // Given
        let customLabel = "Custom accessibility label"
        let logoURLProvider = LogoURLProvider(environment: Dummy.apiContext.environment)

        // When
        let sut = PaymentMethodItem(
            title: "Card",
            logoURLProvider: logoURLProvider,
            accessibilityLabel: customLabel,
            theme: .init()
        )

        // Then
        #expect(sut.accessibilityLabel == customLabel)
    }

    @Test
    func accessibilityLabel_givenNoCustomLabel_shouldCombineTitleAndSubtitle() {
        // Given
        let logoURLProvider = LogoURLProvider(environment: Dummy.apiContext.environment)

        // When
        let sut = PaymentMethodItem(
            title: "Credit Card",
            subtitle: "Visa ending in 1234",
            logoURLProvider: logoURLProvider,
            theme: .init()
        )

        // Then
        #expect(sut.accessibilityLabel == "Credit Card, Visa ending in 1234")
    }

    @Test
    func selectionHandler_shouldBeCallable() {
        // Given
        var handlerCalled = false
        let logoURLProvider = LogoURLProvider(environment: Dummy.apiContext.environment)
        let sut = PaymentMethodItem(
            title: "Card",
            logoURLProvider: logoURLProvider,
            theme: .init(),
            selectionHandler: { handlerCalled = true }
        )

        // When
        sut.selectionHandler?()

        // Then
        #expect(handlerCalled == true)
    }

    @Test
    func trailingInfoData_givenLogos_shouldReturnTrailingInfoData() {
        // Given
        let logoNames = ["visa", "mastercard"]
        let trailingInfo = DisplayInformation.TrailingInfoType.logos(named: logoNames, trailingText: nil)
        let logoURLProvider = LogoURLProvider(environment: Dummy.apiContext.environment)

        // When
        let sut = PaymentMethodItem(
            title: "Card",
            trailingInfo: trailingInfo,
            logoURLProvider: logoURLProvider,
            theme: .init()
        )

        // Then
        #expect(sut.trailingInfoData != nil)
        #expect(sut.trailingInfoData?.logoUrls.count == 2)
    }
}
