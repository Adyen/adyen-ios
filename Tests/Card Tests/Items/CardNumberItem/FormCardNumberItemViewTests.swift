//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
import XCTest

class FormCardNumberItemViewTests: XCTestCase {
    
    var item: FormCardNumberItem!
    var sut: FormCardNumberItemView!
    var validator: ValidatorMock!
    
    private static let url = URL(string: "https:google.com")!
    
    override func setUp() {
        item = FormCardNumberItem(cardTypeLogos: [.init(url: Self.url, type: .visa),
                                                  .init(url: Self.url, type: .masterCard)])
        validator = ValidatorMock()
        
        item.validator = validator
        sut = FormCardNumberItemView(item: item)
        
    }
    
    override func tearDown() {
        item = nil
        sut = nil
        validator = nil
    }
    
    func testCustomAccessoryViewWhenValueIsEmpty() {
        let validationExpectation = XCTestExpectation(description: "Expect validator.isValid() to be called.")
        validator.handleIsValid = { _ in
            validationExpectation.fulfill()
            return false
        }
        
        sut.isEditing = true
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)
        
        wait(for: [validationExpectation], timeout: 5)
        
        if case .customView = sut.accessory {} else {
            XCTFail()
        }
    }
    
    func testValidationAccessoryIsInvalidWhenValueIsInvalid() {
        let validationExpectation = XCTestExpectation(description: "Expect validator.isValid() to be called.")
        validator.handleIsValid = { _ in
            validationExpectation.fulfill()
            return false
        }
        
        sut.isEditing = true
        sut.textField.text = "123456"
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)
        
        wait(for: [validationExpectation], timeout: 5)
        XCTAssertEqual(sut.accessory, .invalid)
    }
    
    func testCustomAccessoryViewWhenValueIsValid() {
        let validationExpectation = XCTestExpectation(description: "Expect validator.isValid() to be called.")
        validator.handleIsValid = { _ in
            validationExpectation.fulfill()
            return true
        }
        
        sut.isEditing = true
        sut.textField.text = "5454545454545454"
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)
        
        wait(for: [validationExpectation], timeout: 5)
        if case .customView = sut.accessory {} else {
            XCTFail()
        }
    }

    func testTextFieldSanitizationGivenNonAllowedCharactersShouldSanitizeAndFormatInput() throws {
        // Given
        let cardNumberFormatter = CardNumberFormatter()
        let cardNumberValidator = CardNumberValidator(isLuhnCheckEnabled: true,
                                                      isEnteredBrandSupported: true)
        item.formatter = cardNumberFormatter
        item.validator = cardNumberValidator
        
        XCTAssertEqual(sut.textField.allowsEditingActions, false)

        // When
        sut.textField.text = "4111kdhr456"
        sut.textField.sendActions(for: .editingChanged)

        // Then
        let expectedItemValue = "4111456"
        XCTAssertEqual(expectedItemValue, sut.item.value)

        let expectedItemFormattedValue = "4111 456"
        XCTAssertEqual(expectedItemFormattedValue, sut.item.formattedValue)

        let expectedTextFieldText = sut.item.formattedValue
        XCTAssertEqual(expectedTextFieldText, sut.textField.text)
    }

    func testTextFieldSanitizationGivenCorrectCardNumberShouldSanitizeAndFormatInput() throws {
        // Given
        let cardNumberFormatter = CardNumberFormatter()
        let cardNumberValidator = CardNumberValidator(isLuhnCheckEnabled: true,
                                                      isEnteredBrandSupported: true)
        item.formatter = cardNumberFormatter
        item.validator = cardNumberValidator

        // When
        sut.textField.text = "5555341244441115"
        sut.textField.sendActions(for: .editingChanged)

        // Then
        let expectedItemValue = "5555341244441115"
        XCTAssertEqual(expectedItemValue, sut.item.value)

        let expectedItemFormattedValue = "5555 3412 4444 1115"
        XCTAssertEqual(expectedItemFormattedValue, sut.item.formattedValue)

        let expectedTextFieldText = sut.item.formattedValue
        XCTAssertEqual(expectedTextFieldText, sut.textField.text)
    }
}
