//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
import XCTest

class FormCardNumberItemViewTests: XCTestCase {
    
    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }
    
    func testCustomAccessoryViewWhenValueIsEmpty() {
        let sut = setupSut()
        sut.isEditing = true
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)
        
        if case .customView = sut.accessory {} else {
            XCTFail()
        }
    }
    
    func testValidationAccessoryIsInvalidWhenValueIsInvalid() {
        let validator = ValidatorMock()
        
        let validationExpectation = XCTestExpectation(description: "Expect validator.isValid() to be called.")
        validator.handleIsValid = { _ in
            validationExpectation.fulfill()
            return false
        }
        
        let sut = setupSut(validator: validator)
        sut.isEditing = true
        sut.textField.text = "123456"
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)
        
        wait(for: [validationExpectation], timeout: 10)
        XCTAssertEqual(sut.accessory, .invalid)
    }
    
    func testCustomAccessoryViewWhenValueIsValid() {
        let validator = ValidatorMock()
        
        let validationExpectation = XCTestExpectation(description: "Expect validator.isValid() to be called.")
        validator.handleIsValid = { _ in
            validationExpectation.fulfill()
            return true
        }
        
        let sut = setupSut(validator: validator)
        sut.isEditing = true
        sut.textField.text = "5454545454545454"
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)
        
        wait(for: [validationExpectation], timeout: 10)
        if case .customView = sut.accessory {} else {
            XCTFail()
        }
    }

    func testTextFieldSanitizationGivenNonAllowedCharactersShouldSanitizeAndFormatInput() throws {
        // Given
        let cardNumberFormatter = CardNumberFormatter()
        let cardNumberValidator = CardNumberValidator(
            isLuhnCheckEnabled: true,
            isEnteredBrandSupported: true
        )
        
        let sut = setupSut(
            validator: cardNumberValidator,
            formatter: cardNumberFormatter
        )
        
        XCTAssertEqual(sut.textField.allowsEditingActions, false)

        // When
        sut.textField.text = ""
        _ = sut.textField(sut.textField, shouldChangeCharactersIn: .init(location: 0, length: 0), replacementString: "4111kdhr456")

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
        let cardNumberValidator = CardNumberValidator(
            isLuhnCheckEnabled: true,
            isEnteredBrandSupported: true
        )
        
        let sut = setupSut(
            validator: cardNumberValidator,
            formatter: cardNumberFormatter
        )

        // When
        sut.textField.text = ""
        _ = sut.textField(sut.textField, shouldChangeCharactersIn: .init(location: 0, length: 0), replacementString: "5555341244441115")

        // Then
        let expectedItemValue = "5555341244441115"
        XCTAssertEqual(expectedItemValue, sut.item.value)

        let expectedItemFormattedValue = "5555 3412 4444 1115"
        XCTAssertEqual(expectedItemFormattedValue, sut.item.formattedValue)
        XCTAssertEqual(expectedItemFormattedValue, sut.textField.text)
    }
    
    func test_pasteCardNumberWithExactlyPanLength_shouldCallNotifyDelegateOfMaxLength_Once() {
        
        let panLength = 5
        
        let cardNumberValidator = CardNumberValidator(
            isLuhnCheckEnabled: true,
            isEnteredBrandSupported: true,
            panLength: panLength
        )

        let sut = setupSut(validator: cardNumberValidator)
        
        let setup = makeExpectation_didReachMaximumLength_once(
            for: sut,
            panLength: panLength
        )
        
        // Testing pasting text that's exactly the panLength
        let cardNumberWithExactPanLength = (0..<panLength).reduce("") { $0 + "\($1)" }
        sut.textField.text = cardNumberWithExactPanLength
        sut.textDidChange(textField: sut.textField)
        
        wait(for: [setup.expectation], timeout: 0.1)
    }
    
    func test_enterCardNumberLongerThanPanLength_shouldCallNotifyDelegateOfMaxLength_Once() {
        
        let panLength = 5
        
        let cardNumberValidator = CardNumberValidator(
            isLuhnCheckEnabled: true,
            isEnteredBrandSupported: true,
            panLength: panLength
        )

        let sut = setupSut(validator: cardNumberValidator)
        
        let setup = makeExpectation_didReachMaximumLength_once(
            for: sut,
            panLength: panLength
        )
        
        // Testing "typing" text
        let cardNumberLongerThanPanLength = "5555341244"
        cardNumberLongerThanPanLength.forEach { character in
            sut.textField.text = sut.item.value + String(character)
            sut.textDidChange(textField: sut.textField)
        }
        
        wait(for: [setup.expectation], timeout: 0.1)
    }
    
    func test_deletingCaractersStartingFromLongerThanPanLength_shouldCallNotifyDelegateOfMaxLength_Once() {
        
        let panLength = 5
        
        let cardNumberValidator = CardNumberValidator(
            isLuhnCheckEnabled: true,
            isEnteredBrandSupported: true,
            panLength: panLength
        )

        let sut = setupSut(validator: cardNumberValidator)
        
        let setup = makeExpectation_didReachMaximumLength_once(
            for: sut,
            panLength: panLength
        )
        
        // Testing "deleting" text character by character
        let cardNumberLongerThanPanLength = "5555341244"
        sut.item.value = cardNumberLongerThanPanLength
        cardNumberLongerThanPanLength.forEach { character in
            sut.textField.text = String(sut.item.value.prefix(max(0, sut.item.value.count - 1)))
            sut.textDidChange(textField: sut.textField)
        }
        
        wait(for: [setup.expectation], timeout: 0.1)
    }
    
    func test_pasteCardNumberLongerThanPanLength_shouldCallNotifyDelegateOfMaxLength_Never() {
        
        let panLength = 5
        
        let cardNumberValidator = CardNumberValidator(
            isLuhnCheckEnabled: true,
            isEnteredBrandSupported: true,
            panLength: panLength
        )

        let sut = setupSut(validator: cardNumberValidator)
        
        let setup = makeExpectation_didReachMaximumLength_never(
            for: sut
        )
        
        // Testing pasting text that's longer than the panLength
        let cardNumberWithExactPanLength = (0..<(panLength + 2)).reduce("") { $0 + "\($1)" }
        sut.textField.text = cardNumberWithExactPanLength
        sut.textDidChange(textField: sut.textField)
        
        // We have to hold onto the setup as otherwise
        // the delegate would be released before the end of the test
        _ = setup
    }
}

// MARK: - Helpers

private extension FormCardNumberItemViewTests {
    
    static let url = URL(string: "https://google.com")!
    
    func setupSut(
        validator: Validator = ValidatorMock(),
        formatter: Adyen.Formatter = CardNumberFormatter()
    ) -> FormCardNumberItemView {
        let item = FormCardNumberItem(cardTypeLogos: [
            .init(url: Self.url, type: .visa),
            .init(url: Self.url, type: .masterCard)
        ])
        item.validator = validator
        item.formatter = formatter
        return FormCardNumberItemView(item: item)
    }
    
    /// Sets up an expectation that the `handleDidReachMaximumLength` is called exactly once
    func makeExpectation_didReachMaximumLength_once(
        for sut: FormCardNumberItemView,
        panLength: Int
    ) -> (delegate: FormTextItemViewDelegate, expectation: XCTestExpectation) {
        
        let expectation = expectation(description: "Handle did reach maximum length was called once")
        let delegate = FormTextItemViewDelegateMock<FormCardNumberItem, FormCardNumberItemView>()
        delegate.handleDidReachMaximumLength = { itemView in
            XCTAssertEqual(itemView.textField.text?.count, panLength)
            expectation.fulfill()
        }
        sut.delegate = delegate
        return (delegate, expectation)
    }
    
    /// Sets up an expectation that the `handleDidReachMaximumLength` is never called
    func makeExpectation_didReachMaximumLength_never(
        for sut: FormCardNumberItemView
    ) -> FormTextItemViewDelegate {
        
        let delegate = FormTextItemViewDelegateMock<FormCardNumberItem, FormCardNumberItemView>()
        delegate.handleDidReachMaximumLength = { itemView in
            XCTFail("Should not have called `handleDidReachMaximumLength`")
        }
        sut.delegate = delegate
        return delegate
    }
}
