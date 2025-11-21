//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class FormToggleItemViewThemeTests: XCTestCase {

    func test_formToggleItemView_shouldApplyDefaultStyling() throws {
        let sut = makeSUT()
        let defaultStyle = AdyenSwitchStyle.default

        let toggleLabel = try XCTUnwrap(sut.findLabel())
        XCTAssertEqual(toggleLabel.font, defaultStyle.title.font)
        XCTAssertEqual(toggleLabel.textColor, defaultStyle.title.color)
        XCTAssertEqual(sut.switchControl.onTintColor, defaultStyle.tintColor)

        let stackView = sut.findStackView()
        XCTAssertEqual(stackView?.backgroundColor, defaultStyle.backgroundColor)

        if case let .fixed(radius) = defaultStyle.cornerRadius {
            XCTAssertEqual(stackView?.layer.cornerRadius, radius)
        }
    }

    // MARK: - SUT Factory

    private func makeSUT() -> FormToggleItemView {
        let item = FormToggleItem()
        item.identifier = "testToggleView"
        item.title = "Toggle Label"
        return FormToggleItemView(item: item)
    }

}

// MARK: - Helpers

private extension FormToggleItemView {

    func findLabel() -> UILabel? {
        subviews.compactMap { $0 as? UIStackView }.first?
            .arrangedSubviews.compactMap { $0 as? UILabel }.first
    }

    func findStackView() -> UIStackView? {
        subviews.compactMap { $0 as? UIStackView }.first
    }
}
