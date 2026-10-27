//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class FormContainerItemTests: XCTestCase {

    func test_formContainerItem_shouldBeVisibleByDefault() {
        let item = makeItem()

        let view = item.build(with: FormItemViewBuilder())

        XCTAssertFalse(view.isHidden)
    }

    func test_formContainerItem_whenHiddenBeforeBuild_shouldStartHidden() {
        let item = makeItem()
        item.isHidden.wrappedValue = true

        let view = item.build(with: FormItemViewBuilder())

        XCTAssertTrue(view.isHidden)
    }

    func test_formContainerItem_whenBuiltWithPadding_shouldApplyPaddingInsetsToContent() throws {
        let insets = UIEdgeInsets(top: 1, left: 8, bottom: 2, right: 8)
        let item = makeItem().padding(insets)

        let view = item.build(with: FormItemViewBuilder())

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
        window.addSubview(view)
        view.frame = window.bounds
        window.makeKeyAndVisible()
        window.layoutIfNeeded()

        let contentView = try XCTUnwrap(view.subviews.first)
        XCTAssertEqual(contentView.frame.minX, insets.left)
        XCTAssertEqual(contentView.frame.minY, insets.top)
        XCTAssertEqual(contentView.frame.maxX, view.bounds.width - insets.right)
        XCTAssertEqual(contentView.frame.maxY, view.bounds.height - insets.bottom)
    }

    // MARK: - SUT Factory

    private func makeItem() -> FormLabelItem {
        FormLabelItem(text: "Test", style: TextStyle(font: .systemFont(ofSize: 16), color: .black))
    }
}
