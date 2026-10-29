//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
import XCTest

class FormCardExpiryDateItemViewTests: XCTestCase {
    ///
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

    func testAccessibilityFormatSurvivesValidationAndReset() {
        let item = FormCardExpiryDateItem()
        let sut = makeSUT(item: item)
        let format = localizedString(.cardExpiryItemAccessibilityLabel, nil)
        item.value = "13"
        sut.showValidation()

        let expected = [item.title, format, item.validationFailureMessage].compactMap { $0 }.joined(separator: ", ")
        XCTAssertEqual(sut.accessibilityLabelView?.accessibilityLabel, expected)

        item.title = "Expiration"
        XCTAssertTrue(sut.accessibilityLabelView?.accessibilityLabel?.contains(format) == true)

        sut.reset()
        XCTAssertEqual(sut.accessibilityLabelView?.accessibilityLabel, "Expiration, \(format)")
    }
}

extension FormCardExpiryDateItemViewTests {
    private func makeSUT(item: FormCardExpiryDateItem) -> FormTextInputItemView {
        FormItemViewBuilder().build(with: item)
    }
}
