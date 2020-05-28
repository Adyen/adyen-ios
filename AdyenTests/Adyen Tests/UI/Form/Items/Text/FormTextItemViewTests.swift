//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class FormTextItemViewTests: XCTestCase {
    
    var item: FormTextInputItem!
    var validator: ValidatorMock!
    var formatter: FormatterMock!
    var sut: FormTextItemView<FormTextInputItem>!
    var delegate: FormTextItemViewDelegateMock!
    
    override func setUp() {
        item = FormTextInputItem()
        validator = ValidatorMock()
        formatter = FormatterMock()
        
        item.validator = validator
        item.formatter = formatter
        
        sut = FormTextItemView(item: item)
        
        delegate = FormTextItemViewDelegateMock()
        sut.delegate = delegate
    }
    
    override func tearDown() {
        item = nil
        validator = nil
        formatter = nil
        sut = nil
        delegate = nil
    }
    
    func testDelegateIsCalled() {
        let didReachMaximumLengthExpectation = XCTestExpectation(description: "Expect delegate.didReachMaximumLength() to be called.")
        delegate.handleDidReachMaximumLength = { itemView in
            didReachMaximumLengthExpectation.fulfill()
            XCTAssertTrue(itemView === self.sut)
        }
        
        let didChangeValueExpectation = XCTestExpectation(description: "Expect delegate.didChangeValue() to be called.")
        delegate.handleDidChangeValue = { itemView in
            didChangeValueExpectation.fulfill()
            XCTAssertTrue(itemView === self.sut)
        }
        
        validator.handleMaximumLength = { _ in 6 }
        
        sut.textField.text = "123456H"
        sut.textField.sendActions(for: .editingChanged)
        
        wait(for: [didReachMaximumLengthExpectation,
                   didChangeValueExpectation], timeout: 1)
    }
    
    func testValidatorIsCalled() {
        let formattedTextExpectation = XCTestExpectation(description: "Expect formatter.formattedValue() to be called.")
        formatter.handleFormattedValue = { value in
            formattedTextExpectation.fulfill()
            XCTAssertEqual(value, "123456H")
            return "1234-56"
        }
        
        let sanitizedValueExpectation = XCTestExpectation(description: "Expect formatter.sanitizedValue() to be called.")
        formatter.handleSanitizedValue = { value in
            sanitizedValueExpectation.fulfill()
            XCTAssertEqual(value, "123456H")
            return "123456"
        }
        
        sut.textField.text = "123456H"
        sut.textField.sendActions(for: .editingChanged)
        
        wait(for: [formattedTextExpectation,
                   sanitizedValueExpectation], timeout: 1)
        XCTAssertEqual(sut.textField.text, "1234-56", "sut.textField.text must be the sanitized and formatted text")
        XCTAssertEqual(item.value, "123456", "item.value must be the sanitized non-formatted text")
    }
    
    func tesFormatterIsCalled() {
        let maximumLengthExpectation = XCTestExpectation(description: "Expect validator.maximumLength() to be called.")
        validator.handleMaximumLength = { value in
            XCTAssertEqual(value, "123456")
            maximumLengthExpectation.fulfill()
            return 6
        }
        
        sut.textField.text = "123456H"
        sut.textField.sendActions(for: .editingChanged)
        
        wait(for: [maximumLengthExpectation], timeout: 1)
    }
    
    func testValidationAccessoryIsNoneWhenValueIsEmpty() {
        let validationExpectation = XCTestExpectation(description: "Expect validator.isValid() to be called.")
        validator.handleIsValid = { _ in
            validationExpectation.fulfill()
            return false
        }
        
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)
        
        wait(for: [validationExpectation], timeout: 5)
        XCTAssertEqual(sut.accessory, .none)
    }
    
    func testValidationAccessoryIsInvalidWhenValueIsInvalid() {
        let validationExpectation = XCTestExpectation(description: "Expect validator.isValid() to be called.")
        validator.handleIsValid = { _ in
            validationExpectation.fulfill()
            return false
        }
        
        sut.textField.text = "123456H"
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)
        
        wait(for: [validationExpectation], timeout: 5)
        XCTAssertEqual(sut.accessory, .invalid)
    }
    
    func testValidationAccessoryIsValidWhenValueIsValid() {
        let validationExpectation = XCTestExpectation(description: "Expect validator.isValid() to be called.")
        validator.handleIsValid = { _ in
            validationExpectation.fulfill()
            return true
        }
        
        sut.textField.text = "123456H"
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)
        
        wait(for: [validationExpectation], timeout: 5)
        XCTAssertEqual(sut.accessory, .valid)
    }
    
}
