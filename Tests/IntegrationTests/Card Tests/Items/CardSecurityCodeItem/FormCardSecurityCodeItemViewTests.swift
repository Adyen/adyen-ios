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

    func test_textFieldSanitization_givenNonAllowedCharacters_shouldSanitizeAndFormatInput() {
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

    func test_textFieldSanitization_givenCorrectSecurityCode_shouldSanitizeAndFormatInput() {
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

    func test_shouldChangeCharacters_givenNonAmexAndInputExceedsThreeDigits_shouldReject() {
        // Given
        sut.textField.text = "123"

        // When
        let shouldChange = sut.textField(
            sut.textField,
            shouldChangeCharactersIn: NSRange(location: 3, length: 0),
            replacementString: "4"
        )

        // Then
        XCTAssertFalse(shouldChange)
    }

    func test_shouldChangeCharacters_givenNonAmexAndInputWithinThreeDigits_shouldAllow() {
        // Given
        sut.textField.text = "12"

        // When
        let shouldChange = sut.textField(
            sut.textField,
            shouldChangeCharactersIn: NSRange(location: 2, length: 0),
            replacementString: "3"
        )

        // Then
        XCTAssertTrue(shouldChange)
    }

    func test_shouldChangeCharacters_givenAmexAndInputWithinFourDigits_shouldAllow() {
        // Given
        item.selectedCard = .americanExpress
        sut.textField.text = "123"

        // When
        let shouldChange = sut.textField(
            sut.textField,
            shouldChangeCharactersIn: NSRange(location: 3, length: 0),
            replacementString: "4"
        )

        // Then
        XCTAssertTrue(shouldChange)
    }

    func test_shouldChangeCharacters_givenAmexAndInputExceedsFourDigits_shouldReject() {
        // Given
        item.selectedCard = .americanExpress
        sut.textField.text = "1234"

        // When
        let shouldChange = sut.textField(
            sut.textField,
            shouldChangeCharactersIn: NSRange(location: 4, length: 0),
            replacementString: "5"
        )

        // Then
        XCTAssertFalse(shouldChange)
    }

    func test_shouldChangeCharacters_givenDeletion_shouldAlwaysAllow() {
        // Given
        sut.textField.text = "123"

        // When
        let shouldChange = sut.textField(
            sut.textField,
            shouldChangeCharactersIn: NSRange(location: 2, length: 1),
            replacementString: ""
        )

        // Then
        XCTAssertTrue(shouldChange)
    }

    func test_pasting_givenNonAmexAndMoreThanMaxDigits_shouldAllowAndTruncateValue() {
        // When
        let shouldChange = sut.textField(
            sut.textField,
            shouldChangeCharactersIn: NSRange(location: 0, length: 0),
            replacementString: "1234"
        )
        sut.textField.text = "1234"
        sut.textField.sendActions(for: .editingChanged)

        // Then
        XCTAssertTrue(shouldChange)
        XCTAssertEqual(item.value, "123")
        XCTAssertTrue(item.isValid())
    }

    func test_pasting_givenNonAmexAndValidLength_shouldAllowAndSetValue() {
        // When
        let shouldChange = sut.textField(
            sut.textField,
            shouldChangeCharactersIn: NSRange(location: 0, length: 0),
            replacementString: "123"
        )
        sut.textField.text = "123"
        sut.textField.sendActions(for: .editingChanged)

        // Then
        XCTAssertTrue(shouldChange)
        XCTAssertEqual(item.value, "123")
        XCTAssertTrue(item.isValid())
    }

    func test_pasting_givenAmexAndValidLength_shouldAllowAndSetValue() {
        // Given
        item.formatter = CardSecurityCodeFormatter(publisher: item.$selectedCard)
        item.validator = CardSecurityCodeValidator(publisher: item.$selectedCard)
        item.selectedCard = .americanExpress

        // When
        let shouldChange = sut.textField(
            sut.textField,
            shouldChangeCharactersIn: NSRange(location: 0, length: 0),
            replacementString: "1234"
        )
        sut.textField.text = "1234"
        sut.textField.sendActions(for: .editingChanged)

        // Then
        XCTAssertTrue(shouldChange)
        XCTAssertEqual(item.value, "1234")
        XCTAssertTrue(item.isValid())
    }

    func test_pasting_givenAmexAndMoreThanMaxDigits_shouldAllowAndTruncateValue() {
        // Given
        item.formatter = CardSecurityCodeFormatter(publisher: item.$selectedCard)
        item.validator = CardSecurityCodeValidator(publisher: item.$selectedCard)
        item.selectedCard = .americanExpress

        // When
        let shouldChange = sut.textField(
            sut.textField,
            shouldChangeCharactersIn: NSRange(location: 0, length: 0),
            replacementString: "12345"
        )
        sut.textField.text = "12345"
        sut.textField.sendActions(for: .editingChanged)

        // Then
        XCTAssertTrue(shouldChange)
        XCTAssertEqual(item.value, "1234")
        XCTAssertTrue(item.isValid())
    }

    func test_entering_givenNonAmexAndMoreThanThreeDigits_shouldCapValueAndValidate() {
        // When
        sut.textField.text = "1234"
        sut.textField.sendActions(for: .editingChanged)

        // Then
        XCTAssertEqual(item.value, "123")
        XCTAssertEqual(item.formattedValue, "123")
        XCTAssertTrue(item.isValid())
    }

    func test_entering_givenAmexAndMoreThanFourDigits_shouldCapValueAndValidate() {
        // Given
        item.formatter = CardSecurityCodeFormatter(publisher: item.$selectedCard)
        item.validator = CardSecurityCodeValidator(publisher: item.$selectedCard)
        item.selectedCard = .americanExpress

        // When
        sut.textField.text = "12345"
        sut.textField.sendActions(for: .editingChanged)

        // Then
        XCTAssertEqual(item.value, "1234")
        XCTAssertEqual(item.formattedValue, "1234")
        XCTAssertTrue(item.isValid())
    }

    func test_placeholder_givenNonAmex_shouldShowThreeDigits() {
        assert(for: .masterCard, showsDigits: 3)
    }

    func test_placeholder_givenAmex_shouldShowFourDigits() {
        assert(for: .americanExpress, showsDigits: 4)
    }

    private func assert(
        for cardType: CardType,
        showsDigits digits: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let expectedPlaceholder = localizedString(.cardCvcItemPlaceholderDigits, item.localizationParameters, String(digits))
        item.selectedCard = cardType
        XCTAssertEqual(sut.textField.placeholder, expectedPlaceholder, file: file, line: line)
    }
}
