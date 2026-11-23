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
        let theme = CheckoutTheme(colors: CheckoutColors(textSecondary: .magenta))
        let item = makeItem(theme: theme)

        // When
        let sut = makeSUT(item: item)

        // Then
        let logosView = try #require(sut.firstSubview(of: SupportedPaymentMethodLogosView.self))
        #expect(logosView.style.logoShadowColor == theme.colors.supportShadow)
        #expect(logosView.style.trailingText.color == theme.colors.textOnDisabled)
        #expect(logosView.style.trailingText.font == theme.elements.labels.subheadline.font)
    }

    @Test
    func layout_givenLongTitle_shouldWrapTitleAndKeepLogosWidth() throws {
        // Given
        let shortTitleSUT = makeSUT(item: makeItem(title: "Cards"))
        let longTitleSUT = makeSUT(item: makeItem(title: "Credit and debit cards with a very long payment method name"))

        // When
        let shortTitleSize = layout(shortTitleSUT)
        let longTitleSize = layout(longTitleSUT)

        // Then
        let longTitleLabel = try #require(longTitleSUT.firstSubview(of: AdyenLabel.self))
        #expect(longTitleLabel.numberOfLines == 0)
        #expect(longTitleSize.height > shortTitleSize.height)

        let shortTitleLogos = try #require(shortTitleSUT.firstSubview(of: SupportedPaymentMethodLogosView.self))
        let longTitleLogos = try #require(longTitleSUT.firstSubview(of: SupportedPaymentMethodLogosView.self))
        #expect(longTitleLogos.frame.width == shortTitleLogos.frame.width)
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

    private func layout(_ sut: PaymentMethodItemView) -> CGSize {
        let size = sut.systemLayoutSizeFitting(
            CGSize(width: Constants.itemWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        sut.frame = CGRect(origin: .zero, size: size)
        sut.layoutIfNeeded()
        return size
    }

    private enum Constants {
        static let itemWidth: CGFloat = 343
    }

    private func makeItem(
        title: String = "Card",
        theme: CheckoutTheme = CheckoutTheme()
    ) -> PaymentMethodItem {
        PaymentMethodItem(
            title: title,
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
