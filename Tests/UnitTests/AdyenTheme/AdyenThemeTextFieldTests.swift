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
        let expectedBorderWidth: CGFloat = 2.0
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
    
    func test_textFieldMethod_shouldPreserveDefaultToggleStyle() {
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
        XCTAssertEqual(updatedTheme.toggleStyle.title.font, AdyenLabelStyle().font)
        XCTAssertEqual(updatedTheme.toggleStyle.title.color, AdyenLabelStyle().color)
        XCTAssertEqual(updatedTheme.toggleStyle.tintColor, nil)
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, .clear)
        XCTAssertEqual(updatedTheme.toggleStyle.cornerRadius, CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius))
        XCTAssertEqual(updatedTheme.textFieldStyle.text.color, .systemPink)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.font, .preferredFont(forTextStyle: .title2))
        XCTAssertEqual(updatedTheme.textFieldStyle.text.textAlignment, .left)
    }
    
    func test_textFieldMethod_shouldPreserveDefaultLabelStyle() {
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
        XCTAssertEqual(updatedTheme.labelStyle.font, AdyenFonts.default.body)
        XCTAssertEqual(updatedTheme.labelStyle.color, AdyenColorScheme.default.primary)
        XCTAssertEqual(updatedTheme.labelStyle.disabledColor, AdyenColorScheme.default.disabled)
        XCTAssertEqual(updatedTheme.labelStyle.textAlignment, .natural)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.color, .systemPink)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.font, .preferredFont(forTextStyle: .title2))
        XCTAssertEqual(updatedTheme.textFieldStyle.text.textAlignment, .left)
    }
    
    func test_textFieldMethod_shouldPreserveDefaultButtonStyle() {
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
        XCTAssertEqual(updatedTheme.buttonStyles.primary, AdyenButtonStyles.default.primary)
        XCTAssertEqual(updatedTheme.buttonStyles.secondary, AdyenButtonStyles.default.secondary)
        XCTAssertEqual(updatedTheme.buttonStyles.tertiary, AdyenButtonStyles.default.tertiary)
        XCTAssertEqual(updatedTheme.buttonStyles.destructive, AdyenButtonStyles.default.destructive)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.color, .systemPink)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.font, .preferredFont(forTextStyle: .title2))
        XCTAssertEqual(updatedTheme.textFieldStyle.text.textAlignment, .left)
    }
    
    func test_textFieldMethod_shouldPreserveUpdatedToggleStyle() {
        // Given
        let theme = AdyenTheme()
        let newTextStyle = AdyenLabelStyle(
            font: .preferredFont(forTextStyle: .title2),
            color: .systemPink,
            textAlignment: .left
        )
        
        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.backgroundColor = AdyenColorScheme.default.primary
        newToggleStyle.tintColor = AdyenColorScheme.default.highlight
        newToggleStyle.title = newTextStyle
        newToggleStyle.cornerRadius = CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius)
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.text = newTextStyle
        
        // When
        var updatedTheme = theme.toggle(newToggleStyle)
        updatedTheme = updatedTheme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.toggleStyle.title.font, .preferredFont(forTextStyle: .title2))
        XCTAssertEqual(updatedTheme.toggleStyle.title.color, .systemPink)
        XCTAssertEqual(updatedTheme.toggleStyle.tintColor, AdyenColorScheme.default.highlight)
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, AdyenColorScheme.default.primary)
        XCTAssertEqual(updatedTheme.toggleStyle.cornerRadius, CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius))
        XCTAssertEqual(updatedTheme.textFieldStyle.text.color, .systemPink)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.font, .preferredFont(forTextStyle: .title2))
        XCTAssertEqual(updatedTheme.textFieldStyle.text.textAlignment, .left)
    }
    
    func test_textFieldMethod_shouldPreserveUpdatedLabelStyle() {
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
        var updatedTheme = theme.label(newTextStyle)
        updatedTheme = updatedTheme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.labelStyle.font, .preferredFont(forTextStyle: .title2))
        XCTAssertEqual(updatedTheme.labelStyle.color, .systemPink)
        XCTAssertEqual(updatedTheme.labelStyle.textAlignment, .left)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.color, .systemPink)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.font, .preferredFont(forTextStyle: .title2))
        XCTAssertEqual(updatedTheme.textFieldStyle.text.textAlignment, .left)
    }
    
    func test_textFieldMethod_shouldPreserveUpdatedButtonStyle() {
        // Given
        let theme = AdyenTheme()
        let newButtonStyle = AdyenButtonStyles(colorScheme: .init(primary: .blue))
        let newTextStyle = AdyenLabelStyle(
            font: .preferredFont(forTextStyle: .title2),
            color: .systemPink,
            textAlignment: .left
        )
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        
        newTextFieldStyle.text = newTextStyle
        
        // When
        var updatedTheme = theme.button(newButtonStyle)
        updatedTheme = updatedTheme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.buttonStyles.primary.backgroundColor, .blue)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.color, .systemPink)
        XCTAssertEqual(updatedTheme.textFieldStyle.text.font, .preferredFont(forTextStyle: .title2))
        XCTAssertEqual(updatedTheme.textFieldStyle.text.textAlignment, .left)
    }
}
