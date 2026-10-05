//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenUI
import Testing
import UIKit

@MainActor
struct PaymentMethodItemViewTests {

    @Test("The trailing logos follow the checkout theme rather than the legacy defaults.")
    func init_givenTrailingLogos_shouldStyleThemWithTheTheme() throws {
        // Given
        let theme = CheckoutTheme(colors: CheckoutColors(separator: .cyan, textSecondary: .magenta))
        let item = makeItem(theme: theme)

        // When
        let sut = makeSUT(item: item)

        // Then
        let logosView = try #require(sut.firstSubview(of: SupportedPaymentMethodLogosView.self))
        #expect(logosView.style.images.borderColor == theme.colors.separator)
        #expect(logosView.style.trailingText.color == theme.colors.textSecondary)
        #expect(logosView.style.trailingText.font == theme.elements.labels.subheadline.font)
    }

    // MARK: - Helpers

    private func makeSUT(item: PaymentMethodItem) -> PaymentMethodItemView {
        var sut: PaymentMethodItemView?
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            sut = PaymentMethodItemView(item: item)
        }
        return sut!
    }

    private func makeItem(theme: CheckoutTheme) -> PaymentMethodItem {
        PaymentMethodItem(
            title: "Card",
            trailingInfo: .logos(named: ["visa", "mc", "amex", "maestro"], trailingText: nil),
            logoURLProvider: LogoURLProvider(environment: Dummy.apiContext.environment),
            theme: theme
        )
    }
}

private extension UIView {

    func firstSubview<T: UIView>(of type: T.Type) -> T? {
        if let match = self as? T {
            return match
        }
        return subviews.lazy.compactMap { $0.firstSubview(of: type) }.first
    }
}
