//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class FormLabelItemTests: XCTestCase {

    func test_formLabelItem_shouldApplyStyleAttributes() {
        let customFont = UIFont.systemFont(ofSize: 24, weight: .bold)
        let customColor = UIColor.red
        let style = TextStyle(
            font: customFont,
            color: customColor,
            textAlignment: .right
        )
        let sut = makeSUT(style: style)

        XCTAssertEqual(sut.font, customFont)
        XCTAssertEqual(sut.textColor, customColor)
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
        let item = FormLabelItem(
            text: "Test",
            style: TextStyle(font: .systemFont(ofSize: 16), color: .black),
            identifier: expectedIdentifier
        )
        let builder = FormItemViewBuilder()
        let sut = item.build(with: builder) as? UILabel

        XCTAssertEqual(sut?.accessibilityIdentifier, expectedIdentifier)
    }

    // MARK: - SUT Factory

    private func makeSUT(
        text: String = "Test Label",
        style: TextStyle = TextStyle(font: .systemFont(ofSize: 16), color: .black),
        identifier: String? = "testLabel"
    ) -> UILabel {
        let item = FormLabelItem(text: text, style: style, identifier: identifier)
        let builder = FormItemViewBuilder()
        let view = item.build(with: builder)
        guard let label = view as? UILabel else {
            XCTFail("Expected UILabel but got \(type(of: view))")
            return UILabel()
        }
        return label
    }
}
