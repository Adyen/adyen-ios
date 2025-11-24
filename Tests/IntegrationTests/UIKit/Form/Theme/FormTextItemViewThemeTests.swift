//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class FormTextItemViewThemeTests: XCTestCase {

    func test_formTextItemView_withDefaultTheme_shouldUseDefaultColors() {
        // Given
        let sut = makeSUT()

        // Then
        XCTAssertEqual(sut.titleLabel.textColor, AdyenColors.default.primary)
        XCTAssertEqual(sut.textField.textColor, AdyenColors.default.primary)
        XCTAssertEqual(sut.alertLabel.textColor, AdyenColors.default.destructive)

        let containerView = getContainerView(from: sut)
        XCTAssertEqual(containerView?.backgroundColor, AdyenColors.default.container)
        XCTAssertEqual(containerView?.layer.borderColor, AdyenColors.default.containerOutline.cgColor)
    }

    func test_formTextItemView_withCustomColors_shouldApplyToUI() {
        // Given
        let customColors = AdyenColors(
            container: .systemYellow,
            containerOutline: .systemPurple,
            primary: .systemPink,
            destructive: .systemOrange
        )

        // When
        let sut = makeSUT(colors: customColors)

        // Then
        XCTAssertEqual(sut.titleLabel.textColor, .systemPink)
        XCTAssertEqual(sut.textField.textColor, .systemPink)
        XCTAssertEqual(sut.alertLabel.textColor, .systemOrange)

        let containerView = getContainerView(from: sut)
        XCTAssertEqual(containerView?.backgroundColor, .systemYellow)
        XCTAssertEqual(containerView?.layer.borderColor, UIColor.systemPurple.cgColor)
    }

    func test_formTextItemView_borderColor_shouldUpdateOnEditingStateChange() {
        // Given
        let customColors = AdyenColors(
            containerOutline: .systemGreen,
            primary: .systemOrange
        )
        let sut = makeSUT(colors: customColors)
        let containerView = getContainerView(from: sut)

        // Then - inactive border uses containerOutline
        XCTAssertEqual(containerView?.layer.borderColor, UIColor.systemGreen.cgColor)

        // When - editing triggers active border (uses primary)
        triggerEditing(on: sut, isEditing: true)

        // Then
        XCTAssertEqual(containerView?.layer.borderColor, UIColor.systemOrange.cgColor)

        // When - stop editing
        triggerEditing(on: sut, isEditing: false)

        // Then - back to inactive
        XCTAssertEqual(containerView?.layer.borderColor, UIColor.systemGreen.cgColor)
    }

    func test_formTextInputItemView_isEnabled_shouldApplyCorrectTextColor() {
        // Given
        let customColors = AdyenColors(primary: .systemBlue)
        let item = FormTextInputItem()
        let sut = makeSUT(item: item, colors: customColors)

        // Then - enabled
        XCTAssertEqual(sut.textField.textColor, .systemBlue)
        XCTAssertTrue(sut.textField.isEnabled)

        // When - disable
        setEnabled(false, on: item)

        // Then - disabled color applied (SDK default for disabled is textSecondary)
        XCTAssertEqual(sut.textField.textColor, AdyenColors.default.textSecondary)
        XCTAssertFalse(sut.textField.isEnabled)

        // When - re-enable
        setEnabled(true, on: item)

        // Then - back to custom color
        XCTAssertEqual(sut.textField.textColor, .systemBlue)
        XCTAssertTrue(sut.textField.isEnabled)
    }

    func test_formTextItemView_convenienceInitializer_shouldUseDefaultTheme() {
        // Given & When
        let sut = FormTextItemView(item: FormTextInputItem())

        // Then
        XCTAssertEqual(sut.titleLabel.textColor, AdyenColors.default.primary)
        XCTAssertEqual(sut.textField.textColor, AdyenColors.default.primary)
    }

    // MARK: - SUT Factory

    private func makeSUT(
        item: FormTextInputItem = FormTextInputItem(),
        colors: AdyenColors = .default
    ) -> FormTextInputItemView {
        let theme = AdyenTheme(colors: colors)
        return FormTextInputItemView(item: item, theme: theme)
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
