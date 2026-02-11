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
    
    override func isEmpty() -> Bool {
        value == nil
    }
}

private class FormSelectableValueItemViewMock: FormSelectableValueItemView<String, FormSelectableValueItemMock> {}

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

    func test_selectionHandler() {
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

    func test_valueUpdate() {
        XCTAssertNil(item.formattedValue)
        XCTAssertNil(sut.valueLabel.text)
        XCTAssertEqual(sut.footerLabel.text, placeholderText)

        item.formattedValue = ""
        XCTAssertNil(sut.valueLabel.text)
        XCTAssertEqual(sut.footerLabel.text, placeholderText)

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

    func test_valueLabel_withNoFormattedValue_shouldShowPlaceholder() {
        XCTAssertNil(item.formattedValue)
        XCTAssertNil(sut.valueLabel.text)
        XCTAssertEqual(sut.footerLabel.text, placeholderText)
    }

    func test_valueLabel_withEmptyFormattedValue_shouldShowPlaceholder() {
        item.formattedValue = ""
        XCTAssertNil(sut.valueLabel.text)
        XCTAssertEqual(sut.footerLabel.text, placeholderText)
    }

    func test_valueLabel_withFormattedValue_shouldShowValue() {
        item.formattedValue = "Hello World"
        XCTAssertEqual(sut.valueLabel.text, item.formattedValue)
    }

    // MARK: - Style Tests (Baseline before theme migration)

    func test_titleLabel_shouldUseThemeBodyEmphasizedStyle() {
        // Then - titleLabel is styled by theme (already migrated in FormValueItemView)
        let expectedFont = AdyenTheme.default.elements.labels.bodyEmphasized.font
        XCTAssertEqual(sut.titleLabel.font, expectedFont)
    }

    func test_titleLabel_shouldDisplayItemTitle() {
        // Given
        let customItem = TestFormPickerItem(title: "Custom Title")
        let customSut = FormPickerItemView(item: customItem)

        // Then
        XCTAssertEqual(customSut.titleLabel.text, "Custom Title")
    }

    func test_valueLabel_colorWithValue_shouldUseThemeBodyColor() {
        // Given
        let customItem = TestFormPickerItem()
        customItem.formattedValue = "Has Value"

        // When
        let customSut = FormPickerItemView(item: customItem)

        // Then - Now uses theme.elements.labels.body.color
        XCTAssertEqual(
            customSut.valueLabel.textColor, AdyenTheme.default.elements.labels.body.color
        )
    }

    func test_footerLabel_colorWithPlaceholder_shouldUseThemeTextSecondary() {
        // Given
        let customItem = TestFormPickerItem(placeholder: "Placeholder")
        customItem.formattedValue = nil

        // When
        let customSut = FormPickerItemView(item: customItem)

        // Then - Now uses theme.colors.textSecondary
        XCTAssertEqual(customSut.footerLabel.textColor, AdyenTheme.default.colors.textSecondary)
    }

    func test_valueLabel_whenFormattedValueChanges_shouldUpdateColorToThemeBodyColor() {
        // Given
        let customItem = TestFormPickerItem()
        customItem.formattedValue = nil
        let customSut = FormPickerItemView(item: customItem)
        XCTAssertEqual(customSut.footerLabel.textColor, AdyenTheme.default.colors.textSecondary) // placeholder color

        // When
        customItem.formattedValue = "New Value"

        // Then - Now uses theme.elements.labels.body.color
        XCTAssertEqual(
            customSut.valueLabel.textColor, AdyenTheme.default.elements.labels.body.color
        )
    }

    func test_chevronView_shouldExist() {
        XCTAssertNotNil(sut.chevronView)
        XCTAssertNotNil(sut.chevronView.image)
    }

    // MARK: - TitleLabel Complete Style Tests

    func test_titleLabel_color_shouldUseThemeBodyEmphasizedColor() {
        // Then - titleLabel color is styled by theme (already migrated in FormValueItemView)
        let expectedColor = AdyenTheme.default.elements.labels.bodyEmphasized.color
        XCTAssertEqual(sut.titleLabel.textColor, expectedColor)
    }

    // MARK: - ValueLabel Font Tests

    func test_valueLabel_font_shouldUseThemeBodyFont() {
        // Then - Now uses theme.elements.labels.body.font
        XCTAssertEqual(sut.valueLabel.font, AdyenTheme.default.elements.labels.body.font)
    }

    // MARK: - FooterLabel Style Tests

    func test_footerLabel_color_shouldUseThemeDestructiveColor() {
        // Given - force validation to show error state
        sut.showValidation()
        
        // Then - footerLabel uses destructive color when showing error
        let expectedColor = AdyenTheme.default.colors.destructive
        XCTAssertEqual(
            sut.footerLabel.textColor?.resolvedColor(
                with: UITraitCollection(userInterfaceStyle: .light)
            ),
            expectedColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        )
    }

    func test_footerLabel_font_shouldUseThemeSubheadlineStyle() {
        // Then - footerLabel font is styled by theme
        let expectedFont = AdyenTheme.default.elements.labels.subheadline.font
        XCTAssertEqual(sut.footerLabel.font, expectedFont)
    }

    func test_footerLabel_text_shouldUseItemValidationFailureMessage() {
        // Given - force validation to show error message
        sut.showValidation()
        
        // Then - TestFormPickerItem sets validationFailureMessage in updateValidationFailureMessage()
        XCTAssertEqual(sut.footerLabel.text, "Please select a value")
    }

    // MARK: - View-Level Style Tests

    func test_view_tintColor_shouldUseStyleTintColor() {
        // Given - Current behavior: uses item.style.tintColor
        var style = FormTextItemStyle()
        style.tintColor = .systemPurple
        let customItem = TestFormPickerItem(style: style)

        // When
        let customSut = FormPickerItemView(item: customItem)

        // Then - Currently reads from item.style.tintColor
        XCTAssertEqual(customSut.tintColor, .systemPurple)
    }

    func test_view_backgroundColor_shouldUseStyleBackgroundColor() {
        // Given - Current behavior: uses item.style.backgroundColor
        var style = FormTextItemStyle()
        style.backgroundColor = .yellow
        let customItem = TestFormPickerItem(style: style)

        // When
        let customSut = FormPickerItemView(item: customItem)

        // Then - Currently reads from item.style.backgroundColor
        XCTAssertEqual(customSut.backgroundColor, .yellow)
    }
}
