//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class AdyenThemeTextFieldTests: XCTestCase {
    
    func test_textFieldMethod_defaultTheme() {
        // Given
        let defaultTheme = AdyenTheme()
        
        // Then
        XCTAssertEqual(defaultTheme.textFieldStyle.backgroundColor, AdyenColorScheme.default.background)
        XCTAssertEqual(defaultTheme.textFieldStyle.textColor, AdyenColorScheme.default.text)
        XCTAssertEqual(defaultTheme.textFieldStyle.activeColor, AdyenColorScheme.default.highlight)
        XCTAssertEqual(defaultTheme.textFieldStyle.errorColor, AdyenColorScheme.default.destructive)
        XCTAssertEqual(defaultTheme.textFieldStyle.cornerRadius, CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius))
        XCTAssertEqual(defaultTheme.textFieldStyle.borderColor, AdyenColorScheme.default.outline)
        XCTAssertEqual(defaultTheme.textFieldStyle.borderWidth, AdyenUIConstants.defaultBorderWidth)
    }

    func test_textfieldMethod_shouldUpdateBackgroundColor() {
        // Given
        let theme = AdyenTheme()
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.backgroundColor = AdyenColorScheme.default.primary
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.backgroundColor, AdyenColorScheme.default.primary)
    }
    
    func test_textfieldMethod_shouldUpdateTextColor() {
        // Given
        let theme = AdyenTheme()
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.textColor = AdyenColorScheme.default.textOnPrimary
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.textColor, AdyenColorScheme.default.textOnPrimary)
    }
    
    func test_textfieldMethod_shouldUpdateActiveColor() {
        // Given
        let theme = AdyenTheme()
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.activeColor = AdyenColorScheme.default.highlight
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.activeColor, AdyenColorScheme.default.highlight)
    }
    
    func test_textfieldMethod_shouldUpdateErrorColor() {
        // Given
        let theme = AdyenTheme()
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.errorColor = AdyenColorScheme.default.textOnDestructive
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.errorColor, AdyenColorScheme.default.textOnDestructive)
    }
    
    func test_textfieldMethod_shouldUpdateBorderColor() {
        // Given
        let theme = AdyenTheme()
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.borderColor = AdyenColorScheme.default.outline
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.borderColor, AdyenColorScheme.default.outline)
    }
    
    func test_textFieldMethod_shouldUpdateCornerRadius() {
        let expectedCornerRadius: CGFloat = 10.0
        
        // Given
        let cornerRadius = CornerRounding.fixed(expectedCornerRadius)
        let theme = AdyenTheme()
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        
        newTextFieldStyle.cornerRadius = cornerRadius
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.cornerRadius, cornerRadius)
    }
    
    func test_textFieldMethod_shouldUpdateBorderWidth() {
        let expectedBorderWidth: CGFloat = 2.0
        // Given
        let theme = AdyenTheme()
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        
        newTextFieldStyle.borderWidth = expectedBorderWidth
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.borderWidth, expectedBorderWidth)
    }
    
    func test_textFieldMethod_shouldUpdateTitleStyle() {
        // Given
        let theme = AdyenTheme()
        
        let newTitleStyle = AdyenLabelStyle(
            font: .preferredFont(forTextStyle: .title1),
            color: .red,
            textAlignment: .natural
        )
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        
        newTextFieldStyle.title = newTitleStyle
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.title.color, .red)
        XCTAssertEqual(updatedTheme.textFieldStyle.title.font, .preferredFont(forTextStyle: .title1))
        XCTAssertEqual(updatedTheme.textFieldStyle.title.textAlignment, .natural)
    }
    
    func test_textFieldMethod_shouldUpdateTextStyle() {
        // Given
        let theme = AdyenTheme()
        
        let newTextStyle = AdyenLabelStyle(
            font: .preferredFont(forTextStyle: .title2),
            color: .systemPink,
            textAlignment: .left
        )
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        
        newTextFieldStyle.text = newTextStyle
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.text.color, .systemPink)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.font, .preferredFont(forTextStyle: .title2))
        XCTAssertEqual(updatedTheme.textFieldStyle.text.textAlignment, .left)
    }
    
    func test_textFieldMethod_shouldUpdatePlaceholderStyle() {
        // Given
        let theme = AdyenTheme()
        
        let newPlaceholderTextStyle = AdyenLabelStyle(
            font: .preferredFont(forTextStyle: .footnote),
            color: .red,
            textAlignment: .right
        )
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        
        newTextFieldStyle.placeholderText = newPlaceholderTextStyle
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.placeholderText?.color, .red)
        XCTAssertEqual(updatedTheme.textFieldStyle.placeholderText?.font, .preferredFont(forTextStyle: .footnote))
        XCTAssertEqual(updatedTheme.textFieldStyle.placeholderText?.textAlignment, .right)
    }
}
