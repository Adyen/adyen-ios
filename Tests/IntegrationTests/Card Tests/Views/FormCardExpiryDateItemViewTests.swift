///
/// Copyright (c) 2021 Adyen N.V.
///
/// This file is open source and available under the MIT license. See the LICENSE file for more info.
///

@_spi(AdyenInternal) import Adyen
@testable import AdyenCard
import XCTest

class FormCardExpiryDateItemViewTests: XCTestCase {
    
    func testAccessibilityLabelWithEmptyTitle() {
        // Given
        let sut = makeSUT(item: FormCardExpiryDateItem())
        sut.item.title = nil

        // Due to unconventional behavior of `AdyenObservable` compared
        // to other reactive frameworks this needs to be here as publisher doesn't
        // publish if new value is the same as old value
        sut.item.placeholder = nil

        // When placeholder is updated
        sut.item.placeholder = "MM/YY"

        // Then
        XCTAssertEqual(sut.textField.accessibilityLabel, "MM/YY")
    }
    
    func testAccessibilityLabelWithTitle() {
        // Given
        let sut = makeSUT(item: FormCardExpiryDateItem())

        sut.item.title = "Expiry date"
        sut.item.placeholder = nil

        // When placeholder is updated
        sut.item.placeholder = "MM/YY"

        // Then
        XCTAssertEqual(sut.textField.accessibilityLabel, "Expiry date, MM/YY")
    }
    
    func testAccessibilityLabelWhenPlaceholderChanges() {
        // Given
        let sut = makeSUT(item: FormCardExpiryDateItem())
        sut.item.title = "Expiry date"
        sut.item.placeholder = "MM/YY"

        // When placeholder is updated
        sut.item.placeholder = "MM/YYYY"
        
        // Then
        XCTAssertEqual(sut.textField.accessibilityLabel, "Expiry date, MM/YYYY")
    }
    
    func testAccessibilityLabelWhenTitleChanges() {
        // Given
        let sut = makeSUT(item: FormCardExpiryDateItem())
        sut.item.title = "Expiry date"
        sut.item.placeholder = "MM/YY"

        // When title is updated
        sut.item.title = "Card expiration date"

        // Then
        XCTAssertEqual(sut.textField.accessibilityLabel, "Card expiration date, MM/YY")
    }

    func testAccessibilityLabelSetWithoutItemUpdates() {
        // Given
        let item = FormCardExpiryDateItem()
        item.title = "Expiry date"
        item.placeholder = "MM/YY"

        // When view is created
        let sut = makeSUT(item: item)

        // Then
        XCTAssertEqual(sut.textField.accessibilityLabel, "Expiry date, MM/YY")
    }
}

extension FormCardExpiryDateItemViewTests {
    private func makeSUT(item: FormCardExpiryDateItem) -> FormCardExpiryDateItemView {
        FormCardExpiryDateItemView(item: item)
    }
}
