//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class FormCardNumberItemViewTests: XCTestCase {
    
    var item: FormCardNumberItem!
    var sut: FormCardNumberItemView!
    var validator: ValidatorMock!
    
    override func setUp() {
        item = FormCardNumberItem(supportedCardTypes: [.masterCard, .visa, .americanExpress], environment: Environment.test)
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
        
        sut.textField.text = "5454545454545454"
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)
        
        wait(for: [validationExpectation], timeout: 5)
        if case .customView = sut.accessory {} else {
            XCTFail()
        }
    }
}
