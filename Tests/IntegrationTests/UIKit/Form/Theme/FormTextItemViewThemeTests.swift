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
        let sut = makeSUT(with: textFieldStyle)
        expect(sut, toMatchStyle: textFieldStyle)
    }

    func test_formTextItemView_withDefaultTheme_shouldUseDefaultAttributes() {
        let defaultTheme = AdyenTheme.default
        let sut = makeSUT(with: defaultTheme)
        expect(sut, toMatchStyle: defaultTheme.elements.textField)
    }

    func test_formTextItemView_borderColor_shouldUpdateOnEditingStateChange() {
        let sut = makeSUT(borderColor: .green, borderActiveColor: .orange)
        let containerView = getContainerView(from: sut)

        expectBorderColor(containerView, toBe: .green)
        triggerEditing(on: sut, isEditing: true)
        expectBorderColor(containerView, toBe: .orange)
        triggerEditing(on: sut, isEditing: false)
        expectBorderColor(containerView, toBe: .green)
    }

    func test_formTextInputItemView_isEnabled_shouldApplyCorrectTextColor() {
        let item = FormTextInputItem()
        let sut = makeSUT(item: item, textColor: .blue, disabledTextColor: .lightGray)

        XCTAssertEqual(sut.textField.textColor, .blue)
        XCTAssertTrue(sut.textField.isEnabled)

        setEnabled(false, on: item)
        XCTAssertEqual(sut.textField.textColor, .lightGray)
        XCTAssertFalse(sut.textField.isEnabled)

        setEnabled(true, on: item)
        XCTAssertEqual(sut.textField.textColor, .blue)
        XCTAssertTrue(sut.textField.isEnabled)
    }

    func test_formTextItemView_convenienceInitializer_shouldUseDefaultTheme() {
        let sut = FormTextItemView(item: FormTextInputItem())
        let defaultTextFieldStyle = AdyenTheme.default.elements.textField

        XCTAssertEqual(sut.titleLabel.font, defaultTextFieldStyle.title.font)
        XCTAssertEqual(sut.titleLabel.textColor, defaultTextFieldStyle.title.color)
        XCTAssertEqual(sut.textField.font, defaultTextFieldStyle.text.font)
        XCTAssertEqual(sut.textField.textColor, defaultTextFieldStyle.text.color)
    }

    // MARK: - SUT Factory

    private func makeSUT(
        item: FormTextInputItem = FormTextInputItem(),
        with theme: AdyenTheme
    ) -> FormTextItemView<FormTextInputItem> {
        FormTextItemView(item: item, theme: theme)
    }

    private func makeSUT(
        with textFieldStyle: AdyenTextFieldStyle
    ) -> FormTextItemView<FormTextInputItem> {
        let theme = AdyenTheme(elements: AdyenElements(textField: textFieldStyle))
        return makeSUT(with: theme)
    }

    private func makeSUT(
        borderColor: UIColor,
        borderActiveColor: UIColor
    ) -> FormTextItemView<FormTextInputItem> {
        var style = AdyenTextFieldStyle()
        style.borderColor = borderColor
        style.borderActiveColor = borderActiveColor
        return makeSUT(with: style)
    }

    private func makeSUT(
        item: FormTextInputItem,
        textColor: UIColor,
        disabledTextColor: UIColor
    ) -> FormTextInputItemView {
        var style = AdyenTextFieldStyle()
        style.text = AdyenLabelStyle(
            font: .systemFont(ofSize: 16),
            color: textColor,
            disabledColor: disabledTextColor
        )
        let theme = AdyenTheme(elements: AdyenElements(textField: style))
        return FormTextInputItemView(item: item, theme: theme)
    }

    // MARK: - Style Factory

    private func makeTextFieldStyle() -> AdyenTextFieldStyle {
        var style = AdyenTextFieldStyle()
        style.title = AdyenLabelStyle(font: .systemFont(ofSize: 18, weight: .bold), color: .red)
        style.text = AdyenLabelStyle(font: .systemFont(ofSize: 16), color: .blue)
        style.placeholder = AdyenLabelStyle(font: .systemFont(ofSize: 14), color: .gray)
        style.containerColor = .yellow
        style.borderColor = .green
        style.borderWidth = 3.0
        style.cornerRadius = .fixed(12.0)
        style.errorColor = .purple
        return style
    }

    // MARK: - Assertions

    private func expect(
        _ sut: FormTextItemView<FormTextInputItem>,
        toMatchStyle style: AdyenTextFieldStyle,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(sut.titleLabel.font, style.title.font, file: file, line: line)
        XCTAssertEqual(sut.titleLabel.textColor, style.title.color, file: file, line: line)
        XCTAssertEqual(sut.textField.font, style.text.font, file: file, line: line)
        XCTAssertEqual(sut.textField.textColor, style.text.color, file: file, line: line)

        let containerView = getContainerView(from: sut)
        XCTAssertEqual(containerView?.backgroundColor, style.containerColor, file: file, line: line)
        XCTAssertEqual(containerView?.layer.borderWidth, style.borderWidth, file: file, line: line)
        XCTAssertEqual(containerView?.layer.borderColor, style.borderColor.cgColor, file: file, line: line)

        if case let .fixed(radius) = style.cornerRadius {
            XCTAssertEqual(containerView?.layer.cornerRadius, radius, file: file, line: line)
        }

        XCTAssertEqual(sut.alertLabel.textColor, style.errorColor, file: file, line: line)
    }

    private func expectBorderColor(
        _ containerView: UIStackView?,
        toBe color: UIColor,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(containerView?.layer.borderColor, color.cgColor, file: file, line: line)
    }

    // MARK: - Helpers

    private func getContainerView(from sut: FormTextItemView<FormTextInputItem>) -> UIStackView? {
        sut.findView(by: "entryTextStackView")
    }

    private func triggerEditing(on sut: FormTextItemView<FormTextInputItem>, isEditing: Bool) {
        if isEditing {
            sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)
        } else {
            sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)
        }
    }

    private func setEnabled(_ enabled: Bool, on item: FormTextInputItem) {
        item.isEnabled = enabled
        waitForObservableUpdate()
    }

    private func waitForObservableUpdate() {
        let expectation = XCTestExpectation(description: "Wait for observable update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}
