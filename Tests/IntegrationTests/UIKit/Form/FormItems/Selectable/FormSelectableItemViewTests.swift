//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) import AdyenCard
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

private let placeholderText = "Placeholder"

// MARK: - Mocks for FormSelectableValueItemView tests

private class FormSelectableValueItemMock: FormSelectableValueItem<String?> {
    required convenience init() {
        self.init(style: .init(), title: "Title", placeholder: placeholderText)
    }

    init(style: FormTextItemStyle, title: String = "Title", placeholder: String = placeholderText) {
        super.init(value: nil, style: style, placeholder: placeholder)
        self.title = title
    }
}

private class FormSelectableValueItemViewMock: FormSelectableValueItemView<
    String, FormSelectableValueItemMock
>
{}

// MARK: - Test Item (concrete subclass of abstract FormPickerItem)

/// Concrete test implementation of FormPickerItem for testing FormPickerItemView
private class TestFormPickerItem: FormPickerItem<FormPickerElement> {

    convenience init(
        style: FormTextItemStyle = .init(),
        title: String = "Title",
        placeholder: String = placeholderText,
        preselectedValue: FormPickerElement? = nil,
        selectableValues: [FormPickerElement] = []
    ) {
        self.init(
            preselectedValue: preselectedValue,
            selectableValues: selectableValues,
            title: title,
            placeholder: placeholder,
            style: style,
            presenter: nil
        )
    }

    override public func resetValue() {
        value = nil
        formattedValue = nil
    }

    override public func updateValidationFailureMessage() {
        validationFailureMessage = "Please select a value"
    }

    override public func updateFormattedValue() {
        formattedValue = value?.title
    }
}

// MARK: - Tests for FormSelectableValueItemView

class FormSelectableItemViewTests: XCTestCase {

    private var item: FormSelectableValueItemMock!
    private var sut: FormSelectableValueItemViewMock!

    override func setUp() {
        item = FormSelectableValueItemMock()
        sut = FormSelectableValueItemViewMock(item: item)
    }

    override func tearDown() {
        item = nil
        sut = nil
        AdyenAssertion.listener = nil
    }

    func testSelectionHandler() {
        AdyenAssertion.listener = { message in
            XCTAssertEqual(
                message, "'selectionHandler' needs to be provided on 'FormSelectableValueItemMock'"
            )
        }
        sut.selectionButtonTapped()

        let expectation = expectation(description: "selection handler is called")
        item.selectionHandler = { expectation.fulfill() }
        sut.selectionButtonTapped()
        waitForExpectations(timeout: 10)
    }

    func testValueUpdate() {
        XCTAssertNil(item.formattedValue)
        XCTAssertEqual(sut.valueLabel.text, placeholderText)

        item.formattedValue = ""
        XCTAssertEqual(sut.valueLabel.text, placeholderText)

        item.formattedValue = "Hello World"
        XCTAssertEqual(sut.valueLabel.text, item.formattedValue)
    }
}

// MARK: - Tests for FormPickerItemView (real production class)

class FormPickerItemViewStyleTests: XCTestCase {

    private var item: TestFormPickerItem!
    private var sut: FormPickerItemView<FormPickerElement>!

    override func setUp() {
        item = TestFormPickerItem()
        sut = FormPickerItemView(item: item)
    }

    override func tearDown() {
        item = nil
        sut = nil
    }

    // MARK: - Value Update Tests

    func testValueLabel_withNoFormattedValue_shouldShowPlaceholder() {
        XCTAssertNil(item.formattedValue)
        XCTAssertEqual(sut.valueLabel.text, placeholderText)
    }

    func testValueLabel_withEmptyFormattedValue_shouldShowPlaceholder() {
        item.formattedValue = ""
        XCTAssertEqual(sut.valueLabel.text, placeholderText)
    }

    func testValueLabel_withFormattedValue_shouldShowValue() {
        item.formattedValue = "Hello World"
        XCTAssertEqual(sut.valueLabel.text, item.formattedValue)
    }

    // MARK: - Style Tests (Baseline before theme migration)

    func testTitleLabel_shouldUseThemeBodyEmphasizedStyle() {
        // Then - titleLabel is styled by theme (already migrated in FormValueItemView)
        let expectedFont = AdyenTheme.default.elements.labels.bodyEmphasized.font
        XCTAssertEqual(sut.titleLabel.font, expectedFont)
    }

    func testTitleLabel_shouldDisplayItemTitle() {
        // Given
        let customItem = TestFormPickerItem(title: "Custom Title")
        let customSut = FormPickerItemView(item: customItem)

        // Then
        XCTAssertEqual(customSut.titleLabel.text, "Custom Title")
    }

    func testValueLabel_colorWithValue_shouldUseStyleTextColor() {
        // Given - Current behavior: uses item.style.text.color
        var style = FormTextItemStyle()
        style.text.color = .systemBlue
        let customItem = TestFormPickerItem(style: style)
        customItem.formattedValue = "Has Value"

        // When
        let customSut = FormPickerItemView(item: customItem)

        // Then - Currently reads from item.style.text.color
        XCTAssertEqual(customSut.valueLabel.textColor, .systemBlue)
    }

    func testValueLabel_colorWithPlaceholder_shouldUsePlaceholderColor() {
        // Given - Current behavior: uses item.style.placeholderText?.color
        var style = FormTextItemStyle()
        style.placeholderText = TextStyle(font: .systemFont(ofSize: 14), color: .systemGray)
        let customItem = TestFormPickerItem(style: style, placeholder: "Placeholder")
        customItem.formattedValue = nil

        // When
        let customSut = FormPickerItemView(item: customItem)

        // Then - Currently reads from item.style.placeholderText?.color
        XCTAssertEqual(customSut.valueLabel.textColor, .systemGray)
    }

    func testValueLabel_whenFormattedValueChanges_shouldUpdateColorToTextColor() {
        // Given
        var style = FormTextItemStyle()
        style.text.color = .systemGreen
        style.placeholderText = TextStyle(font: .systemFont(ofSize: 14), color: .systemGray)
        let customItem = TestFormPickerItem(style: style)
        customItem.formattedValue = nil
        let customSut = FormPickerItemView(item: customItem)
        XCTAssertEqual(customSut.valueLabel.textColor, .systemGray) // placeholder color

        // When
        customItem.formattedValue = "New Value"

        // Then
        XCTAssertEqual(customSut.valueLabel.textColor, .systemGreen) // text color
    }

    func testChevronView_shouldExist() {
        XCTAssertNotNil(sut.chevronView)
        XCTAssertNotNil(sut.chevronView.image)
    }

    // MARK: - TitleLabel Complete Style Tests

    func testTitleLabel_color_shouldUseThemeBodyEmphasizedColor() {
        // Then - titleLabel color is styled by theme (already migrated in FormValueItemView)
        let expectedColor = AdyenTheme.default.elements.labels.bodyEmphasized.color
        XCTAssertEqual(sut.titleLabel.textColor, expectedColor)
    }

    // MARK: - ValueLabel Font Tests

    func testValueLabel_font_shouldUseStyleTextFont() {
        // Given - Current behavior: uses item.style.text font
        var style = FormTextItemStyle()
        let customFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        style.text.font = customFont
        let customItem = TestFormPickerItem(style: style)

        // When
        let customSut = FormPickerItemView(item: customItem)

        // Then - Currently reads from item.style.text.font
        XCTAssertEqual(customSut.valueLabel.font, customFont)
    }

    // MARK: - AlertLabel Style Tests

    func testAlertLabel_color_shouldUseThemeSubheadlineColor() {
        // BUG DOCUMENTATION: alertLabel.textColor is set to item.style.errorColor, but then
        // alertLabel.apply(theme.elements.labels.subheadline) OVERWRITES it with the subheadline color.
        // This means item.style.errorColor is never actually displayed.
        // The current actual behavior uses theme.elements.labels.subheadline.color (not errorColor)
        let expectedColor = AdyenTheme.default.elements.labels.subheadline.color
        XCTAssertEqual(
            sut.alertLabel.textColor?.resolvedColor(
                with: UITraitCollection(userInterfaceStyle: .light)),
            expectedColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        )
    }

    func testAlertLabel_font_shouldUseThemeSubheadlineStyle() {
        // Then - alertLabel font is styled by theme (in FormValidatableValueItemView)
        let expectedFont = AdyenTheme.default.elements.labels.subheadline.font
        XCTAssertEqual(sut.alertLabel.font, expectedFont)
    }

    func testAlertLabel_text_shouldUseItemValidationFailureMessage() {
        // Given - TestFormPickerItem sets validationFailureMessage in updateValidationFailureMessage()
        // Then
        XCTAssertEqual(sut.alertLabel.text, "Please select a value")
    }

    // MARK: - View-Level Style Tests

    func testView_tintColor_shouldUseStyleTintColor() {
        // Given - Current behavior: uses item.style.tintColor
        var style = FormTextItemStyle()
        style.tintColor = .systemPurple
        let customItem = TestFormPickerItem(style: style)

        // When
        let customSut = FormPickerItemView(item: customItem)

        // Then - Currently reads from item.style.tintColor
        XCTAssertEqual(customSut.tintColor, .systemPurple)
    }

    func testView_backgroundColor_shouldUseStyleBackgroundColor() {
        // Given - Current behavior: uses item.style.backgroundColor
        var style = FormTextItemStyle()
        style.backgroundColor = .systemYellow
        let customItem = TestFormPickerItem(style: style)

        // When
        let customSut = FormPickerItemView(item: customItem)

        // Then - Currently reads from item.style.backgroundColor
        XCTAssertEqual(customSut.backgroundColor, .systemYellow)
    }
}
