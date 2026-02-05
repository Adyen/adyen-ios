//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class TextField_AdyenLabelStyle_Tests: XCTestCase {

    var sut: TextField!

    override func setUp() {
        super.setUp()
        sut = TextField()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests for apply(placeholderText:with:AdyenLabelStyle)

    func test_textField_applyPlaceholder_withAdyenLabelStyle_shouldSetAttributedPlaceholder() {
        // Given
        let placeholderText = "Enter card number"
        let labelStyle = makeAdyenlabelStyle()

        // When
        sut.apply(placeholderText: placeholderText, with: labelStyle)
        
        // Then
        XCTAssertNotNil(sut.attributedPlaceholder)
        XCTAssertEqual(sut.attributedPlaceholder?.string, placeholderText)
        
        // Verify font and color attributes
        let attributes = sut.attributedPlaceholder?.attributes(at: 0, effectiveRange: nil)
        XCTAssertEqual(attributes?[.font] as? UIFont, labelStyle.font)
        XCTAssertEqual(attributes?[.foregroundColor] as? UIColor, labelStyle.color)
    }
    
    func test_textField_applyNilPlaceholderWithAdyenLabelStyle_shouldSetNilAttributedPlaceholder() {
        // Given
        let labelStyle = makeAdyenlabelStyle()

        // When
        sut.apply(placeholderText: nil, with: labelStyle)
        
        // Then
        XCTAssertNil(sut.attributedPlaceholder)
        XCTAssertNil(sut.placeholder)
    }
    
    func testApplyPlaceholderWithAdyenLabelStyle_emptyPlaceholder_shouldClearPreviousPlaceholder() {
        // Given
        let placeholderText = "Test"
        let labelStyle = makeAdyenlabelStyle()
        sut.apply(placeholderText: placeholderText, with: labelStyle)

        // When
        let emptyPlaceholderText = ""
        sut.apply(placeholderText: emptyPlaceholderText, with: labelStyle)

        // Then
        XCTAssertNil(sut.attributedPlaceholder)
        XCTAssertNil(sut.placeholder)
    }
    
    func testApplyPlaceholderWithAdyenLabelStyle_differentFonts_shouldApplyCorrectly() {
        // Given
        let placeholderText = "Test"
        let fonts: [UIFont] = [
            .systemFont(ofSize: 12, weight: .light),
            .systemFont(ofSize: 16, weight: .regular),
            .systemFont(ofSize: 20, weight: .bold),
            .preferredFont(forTextStyle: .headline)
        ]
        
        for font in fonts {
            // Given
            let labelStyle = makeAdyenlabelStyle(font: font)

            // When
            sut.apply(placeholderText: placeholderText, with: labelStyle)
            
            // Then
            let attributes = sut.attributedPlaceholder?.attributes(at: 0, effectiveRange: nil)
            XCTAssertEqual(attributes?[.font] as? UIFont, font, "Font should match for \(font)")
        }
    }
    
    func testApplyPlaceholderWithAdyenLabelStyle_differentColors_shouldApplyCorrectly() {
        // Given
        let placeholderText = "Test"
        let colors: [UIColor] = [
            .red,
            .blue,
            .green,
            UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        ]
        
        for color in colors {
            // Given
            let labelStyle = makeAdyenlabelStyle(color: color)

            // When
            sut.apply(placeholderText: placeholderText, with: labelStyle)
            
            // Then
            let attributes = sut.attributedPlaceholder?.attributes(at: 0, effectiveRange: nil)
            XCTAssertEqual(attributes?[.foregroundColor] as? UIColor, color, "Color should match")
        }
    }
    
    func testApplyPlaceholderWithAdyenLabelStyle_multipleApplications_shouldOverwritePrevious() {
        // Given
        let placeholderText1 = "First placeholder"
        let style1 = AdyenLabelStyle(
            font: .systemFont(ofSize: 12),
            color: .red,
            textAlignment: .left
        )
        
        let placeholderText2 = "Second placeholder"
        let style2 = AdyenLabelStyle(
            font: .systemFont(ofSize: 18),
            color: .blue,
            textAlignment: .right
        )
        
        // When
        sut.apply(placeholderText: placeholderText1, with: style1)
        sut.apply(placeholderText: placeholderText2, with: style2)
        
        // Then
        XCTAssertEqual(sut.attributedPlaceholder?.string, placeholderText2)
        let attributes = sut.attributedPlaceholder?.attributes(at: 0, effectiveRange: nil)
        XCTAssertEqual(attributes?[.font] as? UIFont, style2.font)
        XCTAssertEqual(attributes?[.foregroundColor] as? UIColor, style2.color)
    }

    // MARK: - Helpers

    func makeAdyenlabelStyle(
        font: UIFont = AdyenFonts.default.bodyEmphasized,
        color: UIColor = AdyenColors.default.textOnDisabled,
        textAlignment: NSTextAlignment = .center
    ) -> AdyenLabelStyle {
        AdyenLabelStyle(
            font: font,
            color: color,
            textAlignment: textAlignment
        )
    }

}
