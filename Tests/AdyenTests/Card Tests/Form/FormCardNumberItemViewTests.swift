//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCard
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
}
