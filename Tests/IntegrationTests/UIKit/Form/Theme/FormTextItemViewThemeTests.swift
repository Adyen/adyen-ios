//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class FormTextItemViewThemeTests: XCTestCase {

    func test_formTextItemView_shouldApplyThemeAttributesCorrectly() {
        let textFieldStyle = makeTextFieldStyle()

        let theme = AdyenTheme(elements: AdyenElements(textField: textFieldStyle))
        let item = FormTextInputItem()
        item.title = "Test Title"
        item.placeholder = "Test Placeholder"

        // When
        let sut = FormTextItemView(item: item, theme: theme)

        expect(sut, toMatchStyle: textFieldStyle)
    }

    func test_formTextItemView_withDefaultTheme_shouldUseDefaultAttributes() {
        // Given
        let item = FormTextInputItem()
        let defaultTheme = AdyenTheme.default

        // When
        let sut = FormTextItemView(item: item, theme: defaultTheme)

        // Then
        let containerView: UIStackView? = sut.findView(by: "entryTextStackView")
        XCTAssertEqual(sut.titleLabel.font, defaultTheme.elements.textField.title.font)
        XCTAssertEqual(sut.titleLabel.textColor, defaultTheme.elements.textField.title.color)
        XCTAssertEqual(sut.textField.font, defaultTheme.elements.textField.text.font)
        XCTAssertEqual(sut.textField.textColor, defaultTheme.elements.textField.text.color)
        XCTAssertEqual(containerView?.backgroundColor, defaultTheme.elements.textField.containerColor)
        XCTAssertEqual(sut.alertLabel.textColor, defaultTheme.elements.textField.errorColor)
    }

    func test_formTextItemView_borderColor_shouldUpdateOnEditingStateChange() {
        // Given
        let customBorderColor = UIColor.green
        let customActiveBorderColor = UIColor.orange

        var textFieldStyle = AdyenTextFieldStyle()
        textFieldStyle.borderColor = customBorderColor
        textFieldStyle.borderActiveColor = customActiveBorderColor

        let theme = AdyenTheme(elements: AdyenElements(textField: textFieldStyle))
        let item = FormTextInputItem()

        // When
        let sut = FormTextItemView(item: item, theme: theme)
        let containerView: UIStackView? = sut.findView(by: "entryTextStackView")

        // Then - Not editing
        XCTAssertEqual(containerView?.layer.borderColor, customBorderColor.cgColor)

        // When - Start editing (trigger via text field delegate)
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)

        // Then - Editing
        XCTAssertEqual(containerView?.layer.borderColor, customActiveBorderColor.cgColor)

        // When - Stop editing (trigger via text field delegate)
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)

        // Then - Not editing again
        XCTAssertEqual(containerView?.layer.borderColor, customBorderColor.cgColor)
    }

    func test_formTextInputItemView_isEnabled_shouldApplyCorrectTextColor() {
        // Given
        let customTextColor = UIColor.blue
        let customDisabledTextColor = UIColor.lightGray

        var textFieldStyle = AdyenTextFieldStyle()
        textFieldStyle.text = AdyenLabelStyle(
            font: .systemFont(ofSize: 16),
            color: customTextColor,
            disabledColor: customDisabledTextColor
        )

        let theme = AdyenTheme(elements: AdyenElements(textField: textFieldStyle))
        let item = FormTextInputItem()

        // When
        let sut = FormTextInputItemView(item: item, theme: theme)

        // Then - Initially enabled
        XCTAssertEqual(sut.textField.textColor, customTextColor)
        XCTAssertTrue(sut.textField.isEnabled)

        // When - Disable
        item.isEnabled = false

        // Wait for observable to propagate
        let expectation = XCTestExpectation(description: "Wait for isEnabled change")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Then - Disabled
        XCTAssertEqual(sut.textField.textColor, customDisabledTextColor)
        XCTAssertFalse(sut.textField.isEnabled)

        // When - Re-enable
        item.isEnabled = true

        let expectation2 = XCTestExpectation(description: "Wait for isEnabled change")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 1.0)

        // Then - Enabled again
        XCTAssertEqual(sut.textField.textColor, customTextColor)
        XCTAssertTrue(sut.textField.isEnabled)
    }

    func test_formTextItemView_convenienceInitializer_shouldUseDefaultTheme() {
        // Given
        let item = FormTextInputItem()
        let theme = AdyenTheme.default

        // When
        let sut = FormTextItemView(item: item)

        // Then - Verify default theme is applied by checking its attributes
        XCTAssertEqual(sut.titleLabel.font, theme.elements.textField.title.font)
        XCTAssertEqual(sut.titleLabel.textColor, theme.elements.textField.title.color)
        XCTAssertEqual(sut.textField.font, theme.elements.textField.text.font)
        XCTAssertEqual(sut.textField.textColor, theme.elements.textField.text.color)
    }

    // MARK: - Helpers

    private func makeTextFieldStyle() -> AdyenTextFieldStyle {
        // Given
        let customTitleFont = UIFont.systemFont(ofSize: 18, weight: .bold)
        let customTitleColor = UIColor.red
        let customTextFont = UIFont.systemFont(ofSize: 16)
        let customTextColor = UIColor.blue
        let customPlaceholderFont = UIFont.systemFont(ofSize: 14)
        let customPlaceholderColor = UIColor.gray
        let customBackgroundColor = UIColor.yellow
        let customBorderColor = UIColor.green
        let customBorderWidth: CGFloat = 3.0
        let customCornerRadius: CGFloat = 12.0
        let customErrorColor = UIColor.purple

        var textFieldStyle = AdyenTextFieldStyle()
        textFieldStyle.title = AdyenLabelStyle(font: customTitleFont, color: customTitleColor)
        textFieldStyle.text = AdyenLabelStyle(font: customTextFont, color: customTextColor)
        textFieldStyle.placeholder = AdyenLabelStyle(font: customPlaceholderFont, color: customPlaceholderColor)
        textFieldStyle.containerColor = customBackgroundColor
        textFieldStyle.borderColor = customBorderColor
        textFieldStyle.borderWidth = customBorderWidth
        textFieldStyle.cornerRadius = .fixed(customCornerRadius)
        textFieldStyle.errorColor = customErrorColor

        return textFieldStyle
    }

    private func expect(_ sut: FormTextItemView<FormTextInputItem>, toMatchStyle textFieldStyle: AdyenTextFieldStyle) {
        // Then - Title
        XCTAssertEqual(sut.titleLabel.font, textFieldStyle.title.font)
        XCTAssertEqual(sut.titleLabel.textColor, textFieldStyle.title.color)

        // Then - Text field
        XCTAssertEqual(sut.textField.font, textFieldStyle.text.font)
        XCTAssertEqual(sut.textField.textColor, textFieldStyle.text.color)

        // Then - Container
        let containerView: UIStackView? = sut.findView(by: "entryTextStackView")
        XCTAssertEqual(containerView?.backgroundColor, textFieldStyle.containerColor)
        XCTAssertEqual(containerView?.layer.borderWidth, textFieldStyle.borderWidth)
        XCTAssertEqual(containerView?.layer.borderColor, textFieldStyle.borderColor.cgColor)

        // Then - Corner radius
        if case let .fixed(radius) = textFieldStyle.cornerRadius {
            XCTAssertEqual(containerView?.layer.cornerRadius, radius)
        }

        // Then - Alert/Error
        XCTAssertEqual(sut.alertLabel.textColor, textFieldStyle.errorColor)
    }
}
