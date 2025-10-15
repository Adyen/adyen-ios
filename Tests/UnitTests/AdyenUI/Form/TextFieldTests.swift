//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class TextFieldTests: XCTestCase {
    
    var sut: TextField!
    
    override func setUp() {
        super.setUp()
        sut = TextField()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests for apply(placeholderText:with:TextStyle)
    
    func test_textField_applyPlaceholderWithTextStyle_shouldSetAttributedPlaceholder() {
        // Given
        let placeholderText = "Enter card number"
        let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        let color = UIColor.red
        let textStyle = TextStyle(
            font: font,
            color: color,
            textAlignment: .left
        )
        
        // When
        sut.apply(placeholderText: placeholderText, with: textStyle)
        
        // Then
        XCTAssertNotNil(sut.attributedPlaceholder)
        XCTAssertEqual(sut.attributedPlaceholder?.string, placeholderText)
        
        // Additionally verify font attribute
        let attributes = sut.attributedPlaceholder?.attributes(at: 0, effectiveRange: nil)
        XCTAssertEqual(attributes?[.font] as? UIFont, font)
        XCTAssertEqual(attributes?[.foregroundColor] as? UIColor, color)
    }
    
    func test_textField_applyNilPlaceholderWithTextStyle_shouldSetNilAttributedPlaceholder() {
        // Given
        let textStyle = TextStyle(
            font: .systemFont(ofSize: 14),
            color: .gray,
            textAlignment: .left
        )
        
        // When
        sut.apply(placeholderText: nil, with: textStyle)
        
        // Then
        XCTAssertNil(sut.attributedPlaceholder)
        XCTAssertNil(sut.placeholder)
    }
    
    func test_textField_applyPlaceholder_withNilTextStyle_shouldSetPlainPlaceholder() {
        // Given
        let placeholderText = "Enter text"
        
        // When
        sut.apply(placeholderText: placeholderText, with: nil as TextStyle?)
        
        // Then
        XCTAssertEqual(sut.placeholder, placeholderText)
    }
    
    func test_textField_applyNilPlaceholder_shouldSetEmptyAttributedPlaceholder() throws {
        // Given
        let placeholderText = ""
        let textStyle = TextStyle(
            font: .systemFont(ofSize: 14),
            color: .lightGray,
            textAlignment: .center
        )
        
        // When
        sut.apply(placeholderText: placeholderText, with: textStyle)
        
        // Then
        XCTAssertNil(sut.attributedPlaceholder)
    }
    
}
