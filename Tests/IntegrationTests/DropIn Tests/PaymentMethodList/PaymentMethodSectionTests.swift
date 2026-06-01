//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenDropIn
import Testing

@MainActor
struct PaymentMethodSectionTests {

    @Test
    func init_shouldSetHeaderTitle() {
        // Given
        let expectedTitle = "Stored Payment Methods"
        let logoURLProvider = LogoURLProvider(environment: Dummy.apiContext.environment)
        let item = PaymentMethodItem(title: "Card", logoURLProvider: logoURLProvider, theme: .init())

        // When
        let sut = PaymentMethodSection(
            headerTitle: expectedTitle,
            items: [item],
            theme: .init()
        )

        // Then
        #expect(sut.headerTitle == expectedTitle)
    }

    @Test
    func init_givenNoHeaderTitle_shouldBeNil() {
        // Given
        let logoURLProvider = LogoURLProvider(environment: Dummy.apiContext.environment)
        let item = PaymentMethodItem(title: "Card", logoURLProvider: logoURLProvider, theme: .init())

        // When
        let sut = PaymentMethodSection(items: [item], theme: .init())

        // Then
        #expect(sut.headerTitle == nil)
    }

    @Test
    func init_shouldSetItems() {
        // Given
        let logoURLProvider = LogoURLProvider(environment: Dummy.apiContext.environment)
        let items = [
            PaymentMethodItem(title: "Card", logoURLProvider: logoURLProvider, theme: .init()),
            PaymentMethodItem(title: "iDEAL", logoURLProvider: logoURLProvider, theme: .init())
        ]

        // When
        let sut = PaymentMethodSection(items: items, theme: .init())

        // Then
        #expect(sut.items.count == 2)
        #expect(sut.items[0].title == "Card")
        #expect(sut.items[1].title == "iDEAL")
    }

    @Test
    func init_shouldGenerateUniqueId() {
        // Given
        let logoURLProvider = LogoURLProvider(environment: Dummy.apiContext.environment)
        let item = PaymentMethodItem(title: "Card", logoURLProvider: logoURLProvider, theme: .init())

        // When
        let sut1 = PaymentMethodSection(items: [item], theme: .init())
        let sut2 = PaymentMethodSection(items: [item], theme: .init())

        // Then
        #expect(sut1.id != sut2.id)
    }
}
