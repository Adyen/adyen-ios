//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) import AdyenCard
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
        _ = sut.item.publisher.addEventHandler { event in
            didChangeValueExpectation.fulfill()
        }
        
        validator.handleMaximumLength = { _ in 6 }
        
        sut.textField.text = "123456"
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
    
    func testFormatterIsCalled() {
        let maximumLengthExpectation = XCTestExpectation(description: "Expect validator.maximumLength() to be called.")
        validator.handleMaximumLength = { value in
            XCTAssertEqual(value, "123456")
            maximumLengthExpectation.fulfill()
            return 6
        }
        
        XCTAssertEqual(sut.textField.allowsEditingActions, true)
        
        sut.textField.text = "123456"
        sut.textField.sendActions(for: .editingChanged)
        
        wait(for: [maximumLengthExpectation], timeout: 1)
    }
    
    func testValidationStatusIsNoneWhenValueIsEmpty() {
        let validationExpectation = XCTestExpectation(description: "Expect validator.isValid() to be called.")
        validator.handleIsValid = { _ in
            validationExpectation.fulfill()
            return false
        }
        
        sut.isEditing = true
        
        wait(for: .milliseconds(500))
        
        XCTAssertEqual(sut.separatorView.backgroundColor?.toHexString(), sut.tintColor.toHexString())
        XCTAssertEqual(sut.titleLabel.textColor.toHexString(), sut.tintColor.toHexString())
        
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)
        
        wait(for: [validationExpectation], timeout: 5)
        XCTAssertEqual(sut.accessory, .none)
        
        XCTAssertEqual(sut.separatorView.backgroundColor?.toHexString(), item.style.separatorColor?.toHexString())
        XCTAssertEqual(sut.titleLabel.textColor.toHexString(), item.style.title.color.toHexString())
    }
    
    func testValidationStatusIsInvalidWhenValueIsInvalid() {
        let validationExpectation = XCTestExpectation(description: "Expect validator.isValid() to be called.")
        validator.handleIsValid = { _ in
            validationExpectation.fulfill()
            return false
        }
        
        sut.isEditing = true
        
        wait(for: .milliseconds(500))
        
        XCTAssertEqual(sut.separatorView.backgroundColor?.toHexString(), sut.tintColor.toHexString())
        XCTAssertEqual(sut.titleLabel.textColor.toHexString(), sut.tintColor.toHexString())
        
        sut.textField.text = "123456H"
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)
        
        wait(for: [validationExpectation], timeout: 5)
        XCTAssertEqual(sut.accessory, .invalid)
        
        wait(for: .seconds(1))
        
        XCTAssertEqual(sut.separatorView.backgroundColor?.toHexString(), item.style.errorColor.toHexString())
        XCTAssertEqual(sut.titleLabel.textColor.toHexString(), item.style.errorColor.toHexString())
    }
    
    func testValidationStatusIsValidWhenValueIsValid() {
        let validationExpectation = XCTestExpectation(description: "Expect validator.isValid() to be called.")
        validator.handleIsValid = { _ in
            validationExpectation.fulfill()
            return true
        }
        
        sut.isEditing = true
    
        wait(for: .milliseconds(500))
        
        XCTAssertEqual(sut.separatorView.backgroundColor?.toHexString(), sut.tintColor.toHexString())
        XCTAssertEqual(sut.titleLabel.textColor.toHexString(), sut.tintColor.toHexString())
        
        sut.textField.text = "123456H"
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)
        
        wait(for: [validationExpectation], timeout: 5)
        XCTAssertEqual(sut.accessory, .valid)
        XCTAssertEqual(sut.separatorView.backgroundColor?.toHexString(), sut.tintColor.toHexString())
        XCTAssertEqual(sut.titleLabel.textColor.toHexString(), sut.tintColor.toHexString())
    }

    func testTextFieldSanitizationGivenNonAllowedCharactersShouldSanitizeAndFormatInput() throws {
        // Given
        let validator = CardNumberValidator(isLuhnCheckEnabled: false, isEnteredBrandSupported: false)
        let formatter = CardNumberFormatter()
        item.validator = validator
        item.formatter = formatter
        sut = FormTextItemView(item: item)

        let expectedItemValue = "22224000"
        let expectedFormattedValue = formatter.formattedValue(for: expectedItemValue)

        // When
        sut.textField.text = "2222XF%4000"
        sut.textField.sendActions(for: .editingChanged)

        // Then
        XCTAssertEqual(expectedItemValue, item.value)
        XCTAssertEqual(expectedFormattedValue, item.formattedValue)
        XCTAssertEqual(expectedFormattedValue, sut.textField.text)
    }
}

extension UIColor {
    
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb = Int(r * 255) << 16 | Int(g * 255) << 8 | Int(b * 255) << 0
        return String(format: "#%06x", rgb)
    }
}
