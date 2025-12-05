//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

class FormAddressPickerItemViewStyleTests: XCTestCase {

    private var item: FormAddressPickerItem!
    private var sut: FormAddressPickerItemView!

    override func setUp() {
        item = makeMockItem()
        sut = makeSUT(item: item)
    }

    override func tearDown() {
        item = nil
        sut = nil
    }

    // MARK: - TitleLabel Style Tests

    func test_titleLabel_font_shouldUseThemeBodyEmphasizedFont() {
        let expectedFont = AdyenTheme.default.elements.labels.bodyEmphasized.font
        XCTAssertEqual(sut.titleLabel.font, expectedFont)
    }

    func test_titleLabel_color_shouldUseThemeBodyEmphasizedColor() {
        let expectedColor = AdyenTheme.default.elements.labels.bodyEmphasized.color
        XCTAssertEqual(sut.titleLabel.textColor, expectedColor)
    }

    func test_titleLabel_text_shouldDisplayItemTitle() {
        let expectedText = item.title
        XCTAssertEqual(sut.titleLabel.text, expectedText)
    }

    // MARK: - ValueLabel Style Tests

    func test_valueLabel_font_shouldUseThemeBodyFont() {
        let expectedFont = AdyenTheme.default.elements.labels.body.font
        XCTAssertEqual(sut.valueLabel.font, expectedFont)
    }

    func test_valueLabel_colorWithPlaceholder_shouldUseThemeTextSecondary() {
        // Given - item has no value, so placeholder is shown
        XCTAssertNil(item.formattedValue)

        // Then
        let expectedColor = AdyenTheme.default.colors.textSecondary
        XCTAssertEqual(sut.valueLabel.textColor, expectedColor)
    }

    func test_valueLabel_colorWithValue_shouldUseThemeBodyColor() {
        // Given
        let sutWithValue = makeSUT(prefillAddress: PostalAddressMocks.newYorkPostalAddress)

        // Then
        let expectedColor = AdyenTheme.default.elements.labels.body.color
        XCTAssertEqual(sutWithValue.valueLabel.textColor, expectedColor)
    }

    func test_valueLabel_numberOfLines_shouldBeZeroForMultilineAddress() {
        let expectedNumberOfLines = 0
        XCTAssertEqual(sut.valueLabel.numberOfLines, expectedNumberOfLines)
    }

    // MARK: - AlertLabel Style Tests

    func test_alertLabel_font_shouldUseThemeSubheadlineFont() {
        let expectedFont = AdyenTheme.default.elements.labels.subheadline.font
        XCTAssertEqual(sut.alertLabel.font, expectedFont)
    }

    func test_alertLabel_color_shouldUseThemeDestructiveColor() {
        let expectedColor = AdyenTheme.default.colors.destructive
        XCTAssertEqual(sut.alertLabel.textColor, expectedColor)
    }

    // MARK: - ChevronView Tests

    func test_chevronView_shouldExist() {
        XCTAssertNotNil(sut.chevronView)
        XCTAssertNotNil(sut.chevronView.image)
    }

    // MARK: - Custom Theme Tests

    func test_customTheme_valueLabel_shouldUseCustomBodyColor() {
        // Given
        let expectedColor = UIColor.systemGreen
        let customTheme = AdyenTheme.default.bodyLabel(color: expectedColor)

        // When
        let sutWithCustomTheme = makeSUT(
            prefillAddress: PostalAddressMocks.newYorkPostalAddress,
            theme: customTheme
        )

        // Then
        XCTAssertEqual(sutWithCustomTheme.valueLabel.textColor, expectedColor)
    }

    func test_customTheme_alertLabel_shouldUseCustomDestructiveColor() {
        // Given
        let expectedColor = UIColor.systemPurple
        var customColors = AdyenColors()
        customColors.destructive = expectedColor
        let customTheme = AdyenTheme(colors: customColors)

        // When
        let sutWithCustomTheme = makeSUT(theme: customTheme)

        // Then
        XCTAssertEqual(sutWithCustomTheme.alertLabel.textColor, expectedColor)
    }

    // MARK: - Private

    private func makeMockItem(
        prefillAddress: PostalAddress? = nil
    ) -> FormAddressPickerItem {
        FormAddressPickerItem(
            for: .billing,
            initialCountry: "NL",
            supportedCountryCodes: nil,
            prefillAddress: prefillAddress,
            style: .init(),
            presenter: PresenterMock(present: { _, _ in }, dismiss: { _ in })
        )
    }

    private func makeSUT(
        item: FormAddressPickerItem? = nil,
        prefillAddress: PostalAddress? = nil,
        theme: AdyenTheme = .default
    ) -> FormAddressPickerItemView {
        let resolvedItem = item ?? makeMockItem(prefillAddress: prefillAddress)
        return FormAddressPickerItemView(item: resolvedItem, theme: theme)
    }
}
