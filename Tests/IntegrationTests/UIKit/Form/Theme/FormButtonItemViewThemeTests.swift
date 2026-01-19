//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class FormButtonItemViewThemeTests: XCTestCase {

    func test_formButtonItemView_withCustomTheme_shouldApplyThemeColors() throws {
        // Given - expected colors and custom theme
        let expectedBackgroundColor: UIColor = .purple
        let expectedTextColor: UIColor = .yellow

        let customColors = AdyenColors(
            primary: expectedBackgroundColor,
            textOnPrimary: expectedTextColor
        )
        let customTheme = AdyenTheme(colors: customColors)

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

    func test_formButtonItemView_convenienceInitializer_shouldUseDefaultTheme() throws {
        // Given - using old init
        let item = FormButtonItem()
        item.title = "Submit"
        let expectedBackgroundColor = AdyenColors.default.primary
        let expectedTextColor = AdyenColors.default.textOnPrimary

        // When
        let sut = FormButtonItemView(item: item)

        // Then - should use default theme colors
        let button = try XCTUnwrap(sut.button)
        XCTAssertEqual(button.backgroundColor, expectedBackgroundColor)

        let titleLabel = try XCTUnwrap(button.titleLabel)
        XCTAssertEqual(titleLabel.textColor, expectedTextColor)
    }
}
