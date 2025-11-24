//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class FormButtonItemViewThemeTests: XCTestCase {

    // MARK: - Baseline Test (Current Behavior)

    /// This test captures the CURRENT behavior before theme migration.
    /// SubmitButton is partially migrated - it uses backgroundColor from item.style,
    /// but titleLabel and cornerRadius use default theme values.
    func test_formButtonItemView_withCustomStyle_appliesBackgroundFromStyle() throws {
        // Given - custom button style using the current API
        let customButtonStyle = ButtonStyle(
            title: TextStyle(font: .systemFont(ofSize: 18), color: .systemYellow),
            cornerRounding: .fixed(12),
            background: .systemPurple
        )
        let itemStyle = FormButtonItemStyle(button: customButtonStyle)

        // When - create view with current init
        let item = FormButtonItem(style: itemStyle)
        item.identifier = "testButtonView"
        item.title = "Submit"
        let sut = FormButtonItemView(item: item)

        // Then - backgroundColor comes from item.style
        let submitButton = try XCTUnwrap(sut.submitButton)
        XCTAssertEqual(submitButton.backgroundColor, .systemPurple)

        // Note: titleLabel currently uses default theme colors (AdyenButtonStyle.primary textColor)
        // not the style.title.color - this is the partially migrated state
        let titleLabel = try XCTUnwrap(submitButton.titleLabel)
        let defaultButtonStyle = AdyenButtonStyle.primary(for: .default)
        XCTAssertEqual(titleLabel.textColor, defaultButtonStyle.textColor)

        // Note: Corner radius also comes from default theme (14.0), not from item.style (12.0)
        submitButton.layoutIfNeeded()
        XCTAssertEqual(submitButton.layer.cornerRadius, AdyenUIConstants.defaultCornerRadius)
    }

}
