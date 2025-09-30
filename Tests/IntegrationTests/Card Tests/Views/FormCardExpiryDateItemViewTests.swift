//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

class FormCardExpiryDateItemViewTests: XCTestCase {
//
    func testAccessibilityLabelWithEmptyTitle() {
        // Given
        let sut = makeSUT(item: FormCardExpiryDateItem())
        sut.item.title = nil
        sut.item.placeholder = "MM/YY"

        // Then
        XCTAssertEqual(sut.accessibilityLabelView?.accessibilityLabel, localizedString(.cardExpiryItemAccessibilityLabel, nil))
    }

    func testAccessibilityLabelWithTitle() {
        // Given
        let sut = makeSUT(item: FormCardExpiryDateItem())

        sut.item.title = "Expiry date"
        sut.item.placeholder = nil

        // Then
        let format = localizedString(.cardExpiryItemAccessibilityLabel, nil)
        XCTAssertEqual(sut.accessibilityLabelView?.accessibilityLabel, "Expiry date, \(format)")
    }

    func testAccessibilityLabelWhenTitleChanges() {
        // Given
        let sut = makeSUT(item: FormCardExpiryDateItem())
        sut.item.title = "Expiry date"
        sut.item.placeholder = "MM/YY"

        // When title is updated
        sut.item.title = "Card expiration date"

        // Then
        let format = localizedString(.cardExpiryItemAccessibilityLabel, nil)
        XCTAssertEqual(sut.accessibilityLabelView?.accessibilityLabel, "Card expiration date, \(format)")
    }

    func testAccessibilityLabelSetWithoutItemUpdates() {
        // Given
        let item = FormCardExpiryDateItem()
        item.title = "Expiry date"
        item.placeholder = "MM/YY"

        // When view is created
        let sut = makeSUT(item: item)

        // Then
        let format = localizedString(.cardExpiryItemAccessibilityLabel, nil)
        XCTAssertEqual(sut.accessibilityLabelView?.accessibilityLabel, "Expiry date, \(format)")
    }
}

extension FormCardExpiryDateItemViewTests {
    private func makeSUT(item: FormCardExpiryDateItem) -> FormTextInputItemView {
        let view = FormTextInputItemView(item: item)
        view.observe(item.$title) { _ in
            view.accessibilityLabelView?.accessibilityLabel = item.accessibilityValue
        }
        view.accessibilityLabelView?.accessibilityLabel = item.accessibilityValue
        return view
    }
}
