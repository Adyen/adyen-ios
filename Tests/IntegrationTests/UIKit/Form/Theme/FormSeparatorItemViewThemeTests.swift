//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class FormSeparatorItemViewThemeTests: XCTestCase {

    func test_formSeparatorItemView_shouldApplySeparatorColor() {
        let sut = makeSUT(separatorColor: .red)

        XCTAssertEqual(getSeparatorView(from: sut)?.backgroundColor, .red)
    }

    func test_formSeparatorItemView_shouldHaveCorrectHeight() {
        let sut = makeSUT(separatorColor: .gray)
        let expectedHeight = 1 / UIScreen.main.scale

        let separatorView = getSeparatorView(from: sut)
        let heightConstraint = separatorView?.constraints.first { $0.firstAttribute == .height }

        XCTAssertEqual(heightConstraint?.constant, expectedHeight)
    }

    // TODO: To be removed with the old initializer
    func test_formSeparatorItemView_convenienceInitializer_shouldUseDefaultTheme() {
        let item = FormSeparatorItem(color: .blue)
        item.identifier = "testSeparatorConvenience"
        let sut = FormSeparatorItemView(item: item)

        let separatorView = sut.findView(by: "testSeparatorConvenience.separatorLine") as UIView?
        XCTAssertEqual(separatorView?.backgroundColor, .blue)
    }

    // MARK: - SUT Factory

    private func makeSUT(separatorColor: UIColor) -> FormSeparatorItemView {
        let item = FormSeparatorItem(color: separatorColor)
        item.identifier = "testSeparator"
        let theme = AdyenTheme.default
        return FormSeparatorItemView(item: item, theme: theme)
    }

    // MARK: - Helpers

    private func getSeparatorView(from sut: FormSeparatorItemView) -> UIView? {
        sut.findView(by: "testSeparator.separatorLine")
    }
}
