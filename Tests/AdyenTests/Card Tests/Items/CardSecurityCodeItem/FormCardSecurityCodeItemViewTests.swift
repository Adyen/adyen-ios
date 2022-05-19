//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
import XCTest

class FormCardSecurityCodeItemViewTests: XCTestCase {

    var sut: FormCardSecurityCodeItemView!
    var item: FormCardSecurityCodeItem!
    var validator: CardSecurityCodeValidator!
    var formatter: CardSecurityCodeFormatter!

    override func setUpWithError() throws {
        try super.setUpWithError()
        item = FormCardSecurityCodeItem()
        validator = CardSecurityCodeValidator()
        formatter = CardSecurityCodeFormatter()

        item.validator = validator
        item.formatter = formatter
        sut = FormCardSecurityCodeItemView(item: item)
    }

    override func tearDownWithError() throws {
        validator = nil
        formatter = nil
        item = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testTextFieldSanitizationGivenNonAllowedCharactersShouldSanitizeAndFormatInput() throws {
        // Given
        let expectedCVV = "458"
        let expectedFormattedCVV = formatter.formattedValue(for: expectedCVV)

        // When
        sut.textField.text = "45d8"
        sut.textField.sendActions(for: .editingChanged)

        // Then
        XCTAssertEqual(expectedCVV, item.value)
        XCTAssertEqual(expectedFormattedCVV, item.formattedValue)
        XCTAssertEqual(expectedFormattedCVV, sut.textField.text)
        XCTAssertEqual(sut.textField.allowsEditingActions, false)
    }

    func testTextFieldSanitizationGivenCorrectSecurityCodeShouldSanitizeAndFormatInput() throws {
        // Given
        let expectedCVV = "917"
        let expectedFormattedCVV = formatter.formattedValue(for: expectedCVV)

        // When
        sut.textField.text = "917"
        sut.textField.sendActions(for: .editingChanged)

        // Then
        XCTAssertEqual(expectedCVV, item.value)
        XCTAssertEqual(expectedFormattedCVV, item.formattedValue)
        XCTAssertEqual(expectedFormattedCVV, sut.textField.text)
    }
}
