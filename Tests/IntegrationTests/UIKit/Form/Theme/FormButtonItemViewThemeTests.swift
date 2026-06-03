//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

internal final class FormButtonItemViewThemeTests: XCTestCase {

    internal func test_formButtonItemView_withCustomTheme_shouldApplyThemeColors() throws {
        // Given - expected colors and custom theme
        let expectedBackgroundColor: UIColor = .purple
        let expectedTextColor: UIColor = .yellow

        let customColors = CheckoutColors(
            primary: expectedBackgroundColor,
            textOnPrimary: expectedTextColor
        )
        let customTheme = CheckoutTheme(colors: customColors)

        // When - create view with theme
        let item = FormButtonItem()
        item.identifier = "testButtonView"
        item.title = "Pay Now"
        let sut = FormButtonItemView(item: item, theme: customTheme)

        // Then - button uses expected theme colors
        let button = try XCTUnwrap(sut.button)
        XCTAssertEqual(button.backgroundColor, expectedBackgroundColor)

        let titleLabel = try XCTUnwrap(button.titleLabel)
        XCTAssertEqual(titleLabel.textColor, expectedTextColor)
    }

    internal func test_formButtonItemView_withUpdatedColors_shouldRecreateButtonStyles() throws {
        // Given - update colors via builder on an existing theme
        let expectedBackgroundColor: UIColor = .systemPink
        let expectedTextColor: UIColor = .black

        let customTheme = CheckoutTheme.default
            .colors(
                CheckoutColors(
                    primary: expectedBackgroundColor,
                    textOnPrimary: expectedTextColor
                )
            )

        // When - create view with updated theme
        let item = FormButtonItem()
        item.identifier = "testUpdatedColorsButtonView"
        item.title = "Pay Now"
        let sut = FormButtonItemView(item: item, theme: customTheme)

        // Then - button styles should be recreated from the new colors
        let button = try XCTUnwrap(sut.button)
        XCTAssertEqual(button.backgroundColor, expectedBackgroundColor)

        let titleLabel = try XCTUnwrap(button.titleLabel)
        XCTAssertEqual(titleLabel.textColor, expectedTextColor)
    }

    internal func test_formButtonItemView_convenienceInitializer_shouldUseDefaultTheme() throws {
        // Given - using old init
        let item = FormButtonItem()
        item.title = "Submit"
        let expectedBackgroundColor = CheckoutColors.default.primary
        let expectedTextColor = CheckoutColors.default.textOnPrimary

        // When
        let sut = FormButtonItemView(item: item)

        // Then - should use default theme colors
        let button = try XCTUnwrap(sut.button)
        XCTAssertEqual(button.backgroundColor, expectedBackgroundColor)

        let titleLabel = try XCTUnwrap(button.titleLabel)
        XCTAssertEqual(titleLabel.textColor, expectedTextColor)
    }
}
