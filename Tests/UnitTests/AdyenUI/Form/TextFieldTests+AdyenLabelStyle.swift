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
    
    func testApplyPlaceholderWithAdyenLabelStyle_emptyPlaceholder_shouldSetEmptyAttributedPlaceholder() {
        // Given
        let placeholderText = ""
        let labelStyle = makeAdyenlabelStyle()

        // When
        sut.apply(placeholderText: placeholderText, with: labelStyle)
        
        // Then
        XCTAssertNil(sut.attributedPlaceholder)
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
    
    // MARK: - Comparison tests between TextStyle and AdyenLabelStyle
    
    func testApplyPlaceholder_textStyleAndAdyenLabelStyle_shouldProduceSameResult() {
        // Given
        let placeholderText = "Test placeholder"
        let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        let color = UIColor.purple
        
        let textStyle = TextStyle(
            font: font,
            color: color,
            textAlignment: .left
        )
        
        let labelStyle = AdyenLabelStyle(
            font: font,
            color: color,
            textAlignment: .left
        )
        
        // When - Apply TextStyle
        let textField1 = TextField()
        textField1.apply(placeholderText: placeholderText, with: textStyle)
        
        // When - Apply AdyenLabelStyle
        let textField2 = TextField()
        textField2.apply(placeholderText: placeholderText, with: labelStyle)
        
        // Then - Both should produce the same attributed placeholder
        XCTAssertEqual(textField1.attributedPlaceholder?.string, textField2.attributedPlaceholder?.string)
        
        let attributes1 = textField1.attributedPlaceholder?.attributes(at: 0, effectiveRange: nil)
        let attributes2 = textField2.attributedPlaceholder?.attributes(at: 0, effectiveRange: nil)
        
        XCTAssertEqual(attributes1?[.font] as? UIFont, attributes2?[.font] as? UIFont)
        XCTAssertEqual(attributes1?[.foregroundColor] as? UIColor, attributes2?[.foregroundColor] as? UIColor)
    }

    // MARK: - Helpers

    func makeAdyenlabelStyle(
        font: UIFont = AdyenTheme().currentFonts.bodyEmphasized,
        color: UIColor = AdyenTheme().currentColorScheme.textOnDisabled,
        textAlignment: NSTextAlignment = .center
    ) -> AdyenLabelStyle {
        AdyenLabelStyle(
            font: font,
            color: color,
            textAlignment: textAlignment
        )
    }

}
