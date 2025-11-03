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
        expect(defaultTheme.textFieldStyle, toMatch: AdyenTextFieldStyle())
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
        expect(updatedTheme.textFieldStyle, toMatch: newTextFieldStyle)
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
        expect(updatedTheme.textFieldStyle, toMatch: newTextFieldStyle)
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
        expect(updatedTheme.textFieldStyle, toMatch: newTextFieldStyle)
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
        expect(updatedTheme.textFieldStyle, toMatch: newTextFieldStyle)
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
        expect(updatedTheme.textFieldStyle, toMatch: newTextFieldStyle)
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
        expect(updatedTheme.textFieldStyle.title, matches: newTitleStyle, property: "title")
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
        expect(updatedTheme.textFieldStyle.text, matches: newTextStyle, property: "text")
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
        newTextFieldStyle.placeholder = newPlaceholderTextStyle
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        expect(updatedTheme.textFieldStyle.placeholder, matches: newPlaceholderTextStyle, property: "placeholder")
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
        expect(updatedTheme.toggleStyle, toMatch: AdyenToggleStyle())
        expect(updatedTheme.textFieldStyle, toMatch: newTextFieldStyle)
    }
    
    func test_textFieldMethod_shouldPreserveDefaultLabelStyle() {
        // Given
        let expectedErrorColorValue = UIColor.systemPink
        let theme = AdyenTheme()
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.errorColor = expectedErrorColorValue
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        expect(updatedTheme.labelStyle, toMatch: AdyenLabelStyle())
        expect(updatedTheme.textFieldStyle, toMatch: newTextFieldStyle)
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
        expect(updatedTheme.buttonStyles, toMatch: AdyenButtonStyles.default)
        expect(updatedTheme.textFieldStyle, toMatch: newTextFieldStyle)
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
        expect(updatedTheme.toggleStyle, toMatch: newToggleStyle)
        expect(updatedTheme.toggleStyle.title, matches: newTextStyle, property: "title")
        expect(updatedTheme.textFieldStyle, toMatch: newTextFieldStyle)
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
        expect(updatedTheme.labelStyle, matches: newTextStyle, property: "text")
        expect(updatedTheme.textFieldStyle, toMatch: newTextFieldStyle)
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
        expect(updatedTheme.textFieldStyle, toMatch: newTextFieldStyle)
    }
}
