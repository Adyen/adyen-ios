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
        XCTAssertEqual(defaultTheme.textFieldStyle.activeColor, AdyenColorScheme.default.highlight)
        XCTAssertEqual(defaultTheme.textFieldStyle.errorColor, AdyenColorScheme.default.destructive)
        XCTAssertEqual(defaultTheme.textFieldStyle.cornerRadius, CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius))
        XCTAssertEqual(defaultTheme.textFieldStyle.borderColor, AdyenColorScheme.default.outline)
        XCTAssertEqual(defaultTheme.textFieldStyle.borderWidth, AdyenUIConstants.defaultBorderWidth)
    }

    func test_textfieldMethod_shouldUpdateBackgroundColor() {
        // Given
        let expectedValue = UIColor.green
        let theme = AdyenTheme()
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.backgroundColor = expectedValue
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.backgroundColor, expectedValue)
    }
    
    func test_textfieldMethod_shouldUpdateActiveColor() {
        // Given
        let expectedValue = UIColor.red
        let theme = AdyenTheme()
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.activeColor = expectedValue
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.activeColor, expectedValue)
    }
    
    func test_textfieldMethod_shouldUpdateErrorColor() {
        // Given
        let expectedValue = UIColor.red
        let theme = AdyenTheme()
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.errorColor = expectedValue
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.errorColor, expectedValue)
    }
    
    func test_textfieldMethod_shouldUpdateBorderColor() {
        // Given
        let expectedValue = UIColor.black
        let theme = AdyenTheme()
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.borderColor = expectedValue
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.borderColor, expectedValue)
    }
    
    func test_textFieldMethod_shouldUpdateCornerRadius() {
        // Given
        let expectedCornerRadius: CGFloat = 10.0
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
        // Given
        let expectedBorderWidth: CGFloat = 3.0
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
        let expectedFontValue: UIFont = .preferredFont(forTextStyle: .title1)
        let expectedTitleColorValue = UIColor.red
        let expectedTextAlignmentValue: NSTextAlignment = .left
        let theme = AdyenTheme()
        
        let newTitleStyle = AdyenLabelStyle(
            font: expectedFontValue,
            color: expectedTitleColorValue,
            textAlignment: expectedTextAlignmentValue
        )
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.title = newTitleStyle
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.title.color, expectedTitleColorValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.title.font, expectedFontValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.title.textAlignment, expectedTextAlignmentValue)
    }
    
    func test_textFieldMethod_shouldUpdateTextStyle() {
        // Given
        let expectedFontValue: UIFont = .preferredFont(forTextStyle: .title2)
        let expectedColorValue = UIColor.systemPink
        let expectedTextAlignmentValue: NSTextAlignment = .left
        let theme = AdyenTheme()
        
        let newTextStyle = AdyenLabelStyle(
            font: expectedFontValue,
            color: expectedColorValue,
            textAlignment: expectedTextAlignmentValue
        )
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.text = newTextStyle
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.text.color, expectedColorValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.font, expectedFontValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.textAlignment, expectedTextAlignmentValue)
    }
    
    func test_textFieldMethod_shouldUpdatePlaceholderStyle() {
        // Given
        let expectedFontValue: UIFont = .preferredFont(forTextStyle: .footnote)
        let expectedColorValue = UIColor.red
        let expectedTextAlignmentValue: NSTextAlignment = .right
        let theme = AdyenTheme()
        
        let newPlaceholderTextStyle = AdyenLabelStyle(
            font: expectedFontValue,
            color: expectedColorValue,
            textAlignment: expectedTextAlignmentValue
        )
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.placeholderText = newPlaceholderTextStyle
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.placeholderText?.color, expectedColorValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.placeholderText?.font, expectedFontValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.placeholderText?.textAlignment, expectedTextAlignmentValue)
    }
    
    func test_textFieldMethod_shouldPreserveDefaultToggleStyle() {
        // Given
        let expectedFontValue: UIFont = .preferredFont(forTextStyle: .title2)
        let expectedColorValue = UIColor.systemPink
        let expectedTextAlignmentValue: NSTextAlignment = .left
        let theme = AdyenTheme()
    
        let newTextStyle = AdyenLabelStyle(
            font: expectedFontValue,
            color: expectedColorValue,
            textAlignment: expectedTextAlignmentValue
        )
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.text = newTextStyle
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.toggleStyle.title.font, AdyenLabelStyle().font)
        XCTAssertEqual(updatedTheme.toggleStyle.title.color, AdyenLabelStyle().color)
        XCTAssertEqual(updatedTheme.toggleStyle.tintColor, nil)
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, .clear)
        XCTAssertEqual(updatedTheme.toggleStyle.cornerRadius, CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius))
        XCTAssertEqual(updatedTheme.textFieldStyle.text.color, expectedColorValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.font, expectedFontValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.textAlignment, expectedTextAlignmentValue)
    }
    
    func test_textFieldMethod_shouldPreserveDefaultLabelStyle() {
        // Given
        let expectedFontValue: UIFont = .preferredFont(forTextStyle: .title2)
        let expectedColorValue = UIColor.systemPink
        let expectedTextAlignmentValue: NSTextAlignment = .left
        let theme = AdyenTheme()
    
        let newTextStyle = AdyenLabelStyle(
            font: expectedFontValue,
            color: expectedColorValue,
            textAlignment: expectedTextAlignmentValue
        )
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.text = newTextStyle
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.labelStyle.font, AdyenFonts.default.body)
        XCTAssertEqual(updatedTheme.labelStyle.color, AdyenColorScheme.default.primary)
        XCTAssertEqual(updatedTheme.labelStyle.disabledColor, AdyenColorScheme.default.disabled)
        XCTAssertEqual(updatedTheme.labelStyle.textAlignment, .natural)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.color, expectedColorValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.font, expectedFontValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.textAlignment, expectedTextAlignmentValue)
    }
    
    func test_textFieldMethod_shouldPreserveDefaultButtonStyle() {
        // Given
        let theme = AdyenTheme()
        let expectedFontValue: UIFont = .preferredFont(forTextStyle: .title2)
        let expectedColorValue = UIColor.systemPink
        let expectedTextAlignmentValue: NSTextAlignment = .left

        let newTextStyle = AdyenLabelStyle(
            font: expectedFontValue,
            color: expectedColorValue,
            textAlignment: expectedTextAlignmentValue
        )
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.text = newTextStyle
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.buttonStyles.primary, AdyenButtonStyles.default.primary)
        XCTAssertEqual(updatedTheme.buttonStyles.secondary, AdyenButtonStyles.default.secondary)
        XCTAssertEqual(updatedTheme.buttonStyles.tertiary, AdyenButtonStyles.default.tertiary)
        XCTAssertEqual(updatedTheme.buttonStyles.destructive, AdyenButtonStyles.default.destructive)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.color, expectedColorValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.font, expectedFontValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.textAlignment, expectedTextAlignmentValue)
    }
    
    func test_textFieldMethod_shouldPreserveUpdatedToggleStyle() {
        // Given
        let theme = AdyenTheme()
        let expectedToggleBackgroundColorValue = UIColor.yellow
        let expectedLabelColorValue = UIColor.systemPink
        let expectedToggleTintColorValue = UIColor.blue
        let expectedTextAlignmentValue: NSTextAlignment = .left
        let expectedFontValue: UIFont = .preferredFont(forTextStyle: .title2)
        let expectedCornerRadius: CGFloat = 10.0
        let cornerRadius = CornerRounding.fixed(expectedCornerRadius)
    
        let newTextStyle = AdyenLabelStyle(
            font: expectedFontValue,
            color: expectedLabelColorValue,
            textAlignment: expectedTextAlignmentValue
        )
        
        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.backgroundColor = expectedToggleBackgroundColorValue
        newToggleStyle.tintColor = expectedToggleTintColorValue
        newToggleStyle.title = newTextStyle
        newToggleStyle.cornerRadius = cornerRadius
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.text = newTextStyle
        
        // When
        var updatedTheme = theme.toggle(newToggleStyle)
        updatedTheme = updatedTheme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.toggleStyle.title.font, expectedFontValue)
        XCTAssertEqual(updatedTheme.toggleStyle.title.color, expectedLabelColorValue)
        XCTAssertEqual(updatedTheme.toggleStyle.tintColor, expectedToggleTintColorValue)
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, expectedToggleBackgroundColorValue)
        XCTAssertEqual(updatedTheme.toggleStyle.cornerRadius, cornerRadius)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.color, expectedLabelColorValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.font, expectedFontValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.textAlignment, expectedTextAlignmentValue)
    }
    
    func test_textFieldMethod_shouldPreserveUpdatedLabelStyle() {
        // Given
        let expectedFontValue: UIFont = .preferredFont(forTextStyle: .title2)
        let expectedLabelColorValue = UIColor.systemPink
        let expectedTextAlignment: NSTextAlignment = .left
        let theme = AdyenTheme()
    
        let newTextStyle = AdyenLabelStyle(
            font: expectedFontValue,
            color: expectedLabelColorValue,
            textAlignment: expectedTextAlignment
        )
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        
        newTextFieldStyle.text = newTextStyle
        
        // When
        var updatedTheme = theme.label(newTextStyle)
        updatedTheme = updatedTheme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.labelStyle.font, expectedFontValue)
        XCTAssertEqual(updatedTheme.labelStyle.color, expectedLabelColorValue)
        XCTAssertEqual(updatedTheme.labelStyle.textAlignment, expectedTextAlignment)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.color, expectedLabelColorValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.font, expectedFontValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.textAlignment, expectedTextAlignment)
    }
    
    func test_textFieldMethod_shouldPreserveUpdatedButtonStyle() {
        // Given
        let expectedFontValue: UIFont = .preferredFont(forTextStyle: .title2)
        let expectedLabelColorValue = UIColor.systemPink
        let expectedButtonBackgroundColorValue = UIColor.blue
        let expectedTextAlignment: NSTextAlignment = .left
        let theme = AdyenTheme()
        
        let newButtonStyle = AdyenButtonStyles(colorScheme: .init(primary: expectedButtonBackgroundColorValue))

        let newTextStyle = AdyenLabelStyle(
            font: expectedFontValue,
            color: expectedLabelColorValue,
            textAlignment: expectedTextAlignment
        )
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        
        newTextFieldStyle.text = newTextStyle
        
        // When
        var updatedTheme = theme.button(newButtonStyle)
        updatedTheme = updatedTheme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.buttonStyles.primary.backgroundColor, expectedButtonBackgroundColorValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.color, expectedLabelColorValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.font, expectedFontValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.textAlignment, expectedTextAlignment)
    }
}
