//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class FormLabelItemTests: XCTestCase {

    func test_formLabelItem_shouldApplyThemeAttributes() {
        let customTheme = CheckoutTheme()
            .bodyLabel(
                font: UIFont.systemFont(ofSize: 24, weight: .bold),
                color: .red,
                textAlignment: .right
            )
        let sut = makeSUT(theme: customTheme)

        XCTAssertEqual(sut.font, UIFont.systemFont(ofSize: 24, weight: .bold))
        XCTAssertEqual(sut.textColor, .red)
        XCTAssertEqual(sut.textAlignment, .right)
    }

    func test_formLabelItem_shouldApplyText() {
        let expectedText = "Test Label Text"
        let sut = makeSUT(text: expectedText)

        XCTAssertEqual(sut.text, expectedText)
    }

    func test_formLabelItem_shouldSetNumberOfLinesToZero() {
        let sut = makeSUT()

        XCTAssertEqual(sut.numberOfLines, 0)
    }

    func test_formLabelItem_shouldSetAccessibilityIdentifier() {
        let expectedIdentifier = "testLabel"
        let sut = makeSUT(identifier: expectedIdentifier)

        XCTAssertEqual(sut.accessibilityIdentifier, expectedIdentifier)
    }

    func test_formLabelItem_convenienceInitializer_shouldUseDefaultTheme() {
        let item = FormLabelItem(
            text: "Test",
            style: TextStyle(font: .systemFont(ofSize: 16), color: .black)
        )
        let defaultTheme = CheckoutTheme.default
        let sut = FormLabelItemView(item: item, theme: defaultTheme)

        XCTAssertEqual(sut.textColor, defaultTheme.elements.labels.body.color)
        XCTAssertEqual(sut.font, defaultTheme.elements.labels.body.font)
    }

    func test_formLabelItem_shouldBeVisibleByDefault() {
        let sut = makeSUT()

        XCTAssertFalse(sut.isHidden)
    }

    func test_formLabelItem_whenHiddenBeforeBuild_shouldStartHidden() {
        let item = FormLabelItem(
            text: "Test",
            style: TextStyle(font: .systemFont(ofSize: 16), color: .black)
        )
        item.isHidden.wrappedValue = true

        let view = item.build(with: FormItemViewBuilder())

        XCTAssertTrue(view.isHidden)
    }

    func test_formLabelItem_withFootnoteLabelStyle_shouldApplyFootnoteThemeAttributes() {
        let customTheme = CheckoutTheme()
            .footnoteLabel(
                font: UIFont.systemFont(ofSize: 13, weight: .bold),
                color: .purple
            )
        let sut = makeSUT(theme: customTheme) { $0.elements.labels.footnote }

        XCTAssertEqual(sut.font, UIFont.systemFont(ofSize: 13, weight: .bold))
        XCTAssertEqual(sut.textColor, .purple)
    }

    func test_formLabelItem_withColorOverride_shouldOverrideLabelStyleColor() {
        let customTheme = CheckoutTheme(colors: CheckoutColors(textSecondary: .orange))
        let sut = makeSUT(theme: customTheme) { $0.elements.labels.subheadline.color($0.colors.textSecondary) }

        XCTAssertEqual(sut.font, customTheme.elements.labels.subheadline.font)
        XCTAssertEqual(sut.textColor, .orange)
    }

    // MARK: - SUT Factory

    private func makeSUT(
        text: String = "Test Label",
        theme: CheckoutTheme = .default,
        identifier: String? = "testLabel",
        labelStyle: @escaping (CheckoutTheme) -> AdyenLabelStyle = { $0.elements.labels.body }
    ) -> UILabel {
        let item = FormLabelItem(
            text: text,
            identifier: identifier,
            labelStyle: labelStyle
        )
        let builder = FormItemViewBuilder(theme: theme)
        let view = item.build(with: builder)
        guard let label = view as? UILabel else {
            XCTFail("Expected UILabel but got \(type(of: view))")
            return UILabel()
        }
        return label
    }
}
