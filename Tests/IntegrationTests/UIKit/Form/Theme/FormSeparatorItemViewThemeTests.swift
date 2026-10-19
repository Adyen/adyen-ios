//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class FormSeparatorItemViewThemeTests: XCTestCase {

    func test_formSeparatorItemView_shouldApplyThemeSeparatorColor() {
        let customTheme = CheckoutTheme(colors: CheckoutColors(separator: .red))
        let sut = makeSUT(theme: customTheme)

        XCTAssertEqual(getSeparatorView(from: sut)?.backgroundColor, .red)
    }

    func test_formSeparatorItemView_shouldHaveCorrectHeight() {
        let sut = makeSUT()
        let expectedHeight = 1 / UIScreen.main.scale

        let separatorView = getSeparatorView(from: sut)
        let heightConstraint = separatorView?.constraints.first { $0.firstAttribute == .height }

        XCTAssertEqual(heightConstraint?.constant, expectedHeight)
    }

    func test_formSeparatorItemView_convenienceInitializer_shouldUseDefaultTheme() {
        let item = FormSeparatorItem(color: .blue)
        item.identifier = "testSeparatorConvenience"
        let sut = FormSeparatorItemView(item: item)

        let separatorView = sut.findView(by: "testSeparatorConvenience.separatorLine") as UIView?
        XCTAssertEqual(separatorView?.backgroundColor, CheckoutTheme.default.colors.separator)
    }

    // MARK: - SUT Factory

    private func makeSUT(theme: CheckoutTheme = .default) -> FormSeparatorItemView {
        let item = FormSeparatorItem(color: .blue)
        item.identifier = "testSeparator"
        return FormSeparatorItemView(item: item, theme: theme)
    }

    // MARK: - Helpers

    private func getSeparatorView(from sut: FormSeparatorItemView) -> UIView? {
        sut.findView(by: "testSeparator.separatorLine")
    }
}
