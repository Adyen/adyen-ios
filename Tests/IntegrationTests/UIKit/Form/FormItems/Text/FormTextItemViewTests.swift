//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import AdyenCard
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

class FormTextItemViewTests: XCTestCase {
    
    var item: FormTextInputItem!
    var validator: ValidatorMock!
    var formatter: FormatterMock!
    var sut: FormTextItemView<FormTextInputItem>!
    var delegate: FormTextItemViewDelegateMock<FormTextInputItem, FormTextItemView<FormTextInputItem>>!
    
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
        
        wait(for: [
            didReachMaximumLengthExpectation,
            didChangeValueExpectation
        ], timeout: 10)
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
        
        wait(for: [
            formattedTextExpectation,
            sanitizedValueExpectation
        ], timeout: 10)
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
        
        wait(for: [maximumLengthExpectation], timeout: 10)
    }
    
    func testValidationStatusIsNoneWhenValueIsEmpty() {
        sut.isEditing = true
        
        wait(for: .milliseconds(500))
        
        XCTAssertEqual(sut.titleLabel.textColor?.toHexString(), sut.theme.elements.textField.title.color.toHexString())
        
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)
        
        XCTAssertEqual(sut.accessory, .none)
    
        XCTAssertEqual(sut.titleLabel.textColor?.toHexString(), sut.theme.elements.textField.text.color.toHexString())
    }
    
    func testValidationStatusIsInvalidWhenValueIsInvalid() {
        let validationExpectation = XCTestExpectation(description: "Expect validator.isValid() to be called.")
        validator.handleIsValid = { _ in
            validationExpectation.fulfill()
            return false
        }
        
        sut.isEditing = true
        
        wait(for: .milliseconds(500))

        XCTAssertEqual(sut.titleLabel.textColor?.toHexString(), sut.theme.elements.textField.title.color.toHexString())
        
        sut.textField.text = "123456H"
        item.value = "123456H" // Set item value so validation has content to validate
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)
        
        wait(for: [validationExpectation], timeout: 10)
        XCTAssertEqual(sut.accessory, .invalid)
        
        wait(for: .seconds(1))
        
        XCTAssertEqual(sut.titleLabel.textColor?.toHexString(), sut.theme.elements.textField.text.color.toHexString())
    }
    
    func testValidationStatusIsValidWhenValueIsValid() {
        let validationExpectation = XCTestExpectation(description: "Expect validator.isValid() to be called.")
        validator.handleIsValid = { _ in
            validationExpectation.fulfill()
            return true
        }
        
        sut.isEditing = true
    
        wait(for: .milliseconds(500))

        XCTAssertEqual(sut.titleLabel.textColor?.toHexString(), sut.theme.elements.textField.title.color.toHexString())
        
        sut.textField.text = "123456H"
        item.value = "123456H" // Set item value so validation has content to validate
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)
        
        wait(for: [validationExpectation], timeout: 10)
        XCTAssertEqual(sut.accessory, .valid)
        XCTAssertEqual(sut.titleLabel.textColor?.toHexString(), sut.theme.elements.textField.text.color.toHexString())
    }

    func testTextFieldSanitizationGivenNonAllowedCharactersShouldSanitizeAndFormatInput() {
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

    // MARK: - Hint Accessory

    func test_hintAccessory_givenEmptyValue_shouldShowHint() {
        // Given
        let hintView = makeHintAccessorySUT()

        // Then
        XCTAssertEqual(sut.accessory, .customView(hintView))
    }

    func test_hintAccessory_whenValueBecomesValidWhileEditing_shouldShowCheckmark() {
        // Given
        let hintView = makeHintAccessorySUT()
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)

        // When
        type("12")

        // Then
        XCTAssertEqual(sut.accessory, .customView(hintView))

        // When
        type("123")

        // Then
        XCTAssertEqual(sut.accessory, .valid)
    }

    func test_hintAccessory_whenValidValueBecomesInvalid_shouldShowHintAgain() {
        // Given
        let hintView = makeHintAccessorySUT()
        type("123")
        XCTAssertEqual(sut.accessory, .valid, "Precondition: checkmark should be shown for a valid value")

        // When
        type("12")

        // Then
        XCTAssertEqual(sut.accessory, .customView(hintView))
    }

    func test_hintAccessory_givenValidValue_whenEditingBeginsAndEnds_shouldKeepCheckmark() {
        // Given
        makeHintAccessorySUT()
        type("123")

        // When
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)

        // Then
        XCTAssertEqual(sut.accessory, .valid)

        // When
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)

        // Then
        XCTAssertEqual(sut.accessory, .valid)
    }

    func test_hintAccessory_givenInvalidValue_whenFocusLost_shouldShowWarningAndHintOnRefocus() {
        // Given
        let hintView = makeHintAccessorySUT()
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)
        type("12")

        // When
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)

        // Then
        XCTAssertEqual(sut.accessory, .invalid)

        // When
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)

        // Then
        XCTAssertEqual(sut.accessory, .customView(hintView))
    }

    @discardableResult
    private func makeHintAccessorySUT() -> UIView {
        validator.handleIsValid = { $0.count == 3 }
        item.formatter = nil
        sut = FormTextItemView(item: item)
        let hintView = UIView()
        sut.hintAccessoryView = hintView
        return hintView
    }

    private func type(_ text: String) {
        sut.textField.text = text
        sut.textField.sendActions(for: .editingChanged)
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
