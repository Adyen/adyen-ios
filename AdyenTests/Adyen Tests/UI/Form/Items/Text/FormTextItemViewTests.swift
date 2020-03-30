//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class FormTextItemViewTests: XCTestCase {
    
    func testDelegateValidatorAndFormatterAreCalled() {
        let item = FormTextInputItem()
        let validator = ValidatorMock()
        let formatter = FormatterMock()
        item.validator = validator
        item.formatter = formatter
        
        let sut = FormTextItemView(item: item)
        let delegate = FormTextItemViewDelegateMock()
        sut.delegate = delegate
        
        // Make sure the delegate is called
        let didReachMaximumLengthExpectation = XCTestExpectation(description: "Expect delegate.didReachMaximumLength() to be called.")
        delegate.handleDidReachMaximumLength = { itemView in
            didReachMaximumLengthExpectation.fulfill()
            XCTAssertTrue(itemView === sut)
        }
        
        let didChangeValueExpectation = XCTestExpectation(description: "Expect delegate.didChangeValue() to be called.")
        delegate.handleDidChangeValue = { itemView in
            didChangeValueExpectation.fulfill()
            XCTAssertTrue(itemView === sut)
        }
        
        // Make sure the formatter is called
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
        
        // Make sure the validator is called
        let maximumLengthExpectation = XCTestExpectation(description: "Expect validator.maximumLength() to be called.")
        validator.handleMaximumLength = { value in
            XCTAssertEqual(value, "123456")
            maximumLengthExpectation.fulfill()
            return 6
        }
        
        sut.textField.text = "123456H"
        sut.textField.sendActions(for: .editingChanged)
        
        wait(for: [didReachMaximumLengthExpectation,
                   didChangeValueExpectation,
                   formattedTextExpectation,
                   sanitizedValueExpectation,
                   maximumLengthExpectation], timeout: 1)
        XCTAssertEqual(sut.textField.text, "1234-56", "sut.textField.text must be the sanitized and formatted text")
        XCTAssertEqual(item.value, "123456", "item.value must be the sanitized non-formatted text")
    }
    
}
