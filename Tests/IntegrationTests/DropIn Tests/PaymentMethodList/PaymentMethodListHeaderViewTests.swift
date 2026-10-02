//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenUI
import Testing
import UIKit

@MainActor
struct PaymentMethodListHeaderViewTests {

    @Test("The subtitle uses the body font with the secondary text color of the theme.")
    func init_shouldStyleTheSubtitleWithTheTheme() throws {
        // Given
        let theme = CheckoutTheme(colors: CheckoutColors(textSecondary: .magenta))
        let viewModel = PaymentMethodListHeaderViewModel(
            title: "€10.00",
            subtitle: "Choose a payment method",
            applePayButtonState: .hidden,
            theme: theme
        )

        // When
        let sut = PaymentMethodListHeaderView(viewModel: viewModel)

        // Then
        let subtitleLabel = try #require(sut.firstLabel(withText: viewModel.subtitle))
        #expect(subtitleLabel.textColor == theme.colors.textSecondary)
        #expect(subtitleLabel.font == theme.elements.labels.body.font)
    }
}

private extension UIView {

    func firstLabel(withText text: String) -> UILabel? {
        if let label = self as? UILabel, label.text == text {
            return label
        }
        return subviews.lazy.compactMap { $0.firstLabel(withText: text) }.first
    }
}
