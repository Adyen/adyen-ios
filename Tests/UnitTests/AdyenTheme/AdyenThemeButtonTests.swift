//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class AdyenThemeButtonTests: XCTestCase {
    
    func test_buttonMethod_defaultTheme() {
        // Given
        let defaultTheme = AdyenTheme()
        
        // Then
        XCTAssertEqual(defaultTheme.buttonStyles.primary, AdyenButtonStyles.default.primary)
        XCTAssertEqual(defaultTheme.buttonStyles.secondary, AdyenButtonStyles.default.secondary)
        XCTAssertEqual(defaultTheme.buttonStyles.tertiary, AdyenButtonStyles.default.tertiary)
        XCTAssertEqual(defaultTheme.buttonStyles.destructive, AdyenButtonStyles.default.destructive)
    }
    
    func test_buttonMethod_shouldUpdateButtonStyles() {
        // Given
        let theme = AdyenTheme()
        let newButtonStyle = AdyenButtonStyles(colorScheme: .init(primary: .blue))
        
        // When
        let updatedTheme = theme.button(newButtonStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.buttonStyles.primary.backgroundColor, .blue)
    }
    
    func test_buttonMethod_shouldPreserveDefaultLabelStyle() {
        // Given
        let theme = AdyenTheme()
        let newButtonStyle = AdyenButtonStyles(colorScheme: .init(primary: .blue))
        
        // When
        let updatedTheme = theme.button(newButtonStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.labelStyle.font, AdyenFonts.default.body)
        XCTAssertEqual(updatedTheme.labelStyle.color, AdyenColorScheme.default.primary)
        XCTAssertEqual(updatedTheme.labelStyle.disabledColor, AdyenColorScheme.default.disabled)
        XCTAssertEqual(updatedTheme.labelStyle.textAlignment, .natural)
        XCTAssertEqual(updatedTheme.buttonStyles.primary.backgroundColor, .blue)
    }
    
    func test_buttonMethod_shouldPreserveDefaultToggleStyle() {
        // Given
        let theme = AdyenTheme()
        let newButtonStyle = AdyenButtonStyles(colorScheme: .init(primary: .blue))
        
        // When
        let updatedTheme = theme.button(newButtonStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.toggleStyle.title.font, AdyenLabelStyle().font)
        XCTAssertEqual(updatedTheme.toggleStyle.title.color, AdyenLabelStyle().color)
        XCTAssertEqual(updatedTheme.toggleStyle.tintColor, nil)
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, .clear)
        XCTAssertEqual(updatedTheme.toggleStyle.cornerRadius, CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius))
        XCTAssertEqual(updatedTheme.buttonStyles.primary.backgroundColor, .blue)
    }
    
    func test_buttonMethod_shouldPreserveDefaultTextFieldStyle() {
        // Given
        let theme = AdyenTheme()
        let newButtonStyle = AdyenButtonStyles(colorScheme: .init(primary: .blue))
        
        // When
        let updatedTheme = theme.button(newButtonStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.backgroundColor, AdyenColorScheme.default.background)
        XCTAssertEqual(updatedTheme.textFieldStyle.textColor, AdyenColorScheme.default.text)
        XCTAssertEqual(updatedTheme.textFieldStyle.activeColor, AdyenColorScheme.default.highlight)
        XCTAssertEqual(updatedTheme.textFieldStyle.errorColor, AdyenColorScheme.default.destructive)
        XCTAssertEqual(updatedTheme.textFieldStyle.cornerRadius, CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius))
        XCTAssertEqual(updatedTheme.textFieldStyle.borderColor, AdyenColorScheme.default.outline)
        XCTAssertEqual(updatedTheme.textFieldStyle.borderWidth, AdyenUIConstants.defaultBorderWidth)
        XCTAssertEqual(updatedTheme.buttonStyles.primary.backgroundColor, .blue)
    }
    
    func test_buttonMethod_shouldPreserveUpdatedLabelStyle() {
        // Given
        let theme = AdyenTheme()
        let newLabelStyle = AdyenLabelStyle(color: .red).font(AdyenFonts.default.bodyEmphasized)
        
        let newButtonStyle = AdyenButtonStyles(colorScheme: .init(primary: .blue))
        
        // When
        var updatedTheme = theme.label(newLabelStyle)
        updatedTheme = updatedTheme.button(newButtonStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.labelStyle.font, AdyenFonts.default.bodyEmphasized)
        XCTAssertEqual(updatedTheme.labelStyle.color, .red)
        XCTAssertEqual(updatedTheme.buttonStyles.primary.backgroundColor, .blue)
    }
    
    func test_buttonMethod_shouldPreserveUpdatedToggleStyle() {
        // Given
        let theme = AdyenTheme()
        let labelStyle = AdyenLabelStyle().color(.red).font(AdyenFonts.default.bodyEmphasized)

        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.backgroundColor = AdyenColorScheme.default.primary
        newToggleStyle.tintColor = AdyenColorScheme.default.highlight
        newToggleStyle.title = labelStyle
        newToggleStyle.cornerRadius = CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius)
        
        let newButtonStyle = AdyenButtonStyles(colorScheme: .init(primary: .yellow))
        
        // When
        var updatedTheme = theme.toggle(newToggleStyle)
        updatedTheme = updatedTheme.button(newButtonStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, AdyenColorScheme.default.primary)
        XCTAssertEqual(updatedTheme.toggleStyle.tintColor, AdyenColorScheme.default.highlight)
        XCTAssertEqual(updatedTheme.toggleStyle.title.font, AdyenFonts.default.bodyEmphasized)
        XCTAssertEqual(updatedTheme.toggleStyle.title.color, .red)
        XCTAssertEqual(updatedTheme.toggleStyle.cornerRadius, CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius))
        XCTAssertEqual(updatedTheme.buttonStyles.primary.backgroundColor, .yellow)
    }
    
    func test_buttonMethod_shouldPreserveUpdatedTextFieldStyle() {
        // Given
        let expectedBorderWidth: CGFloat = 2.0
        let expectedCornerRadius: CGFloat = 10.0
        let cornerRadius = CornerRounding.fixed(expectedCornerRadius)
        let theme = AdyenTheme()
    
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.backgroundColor = AdyenColorScheme.default.primary
        newTextFieldStyle.textColor = AdyenColorScheme.default.textOnPrimary
        newTextFieldStyle.activeColor = AdyenColorScheme.default.highlight
        newTextFieldStyle.errorColor = AdyenColorScheme.default.textOnDestructive
        newTextFieldStyle.borderColor = AdyenColorScheme.default.outline
        newTextFieldStyle.cornerRadius = cornerRadius
        newTextFieldStyle.borderWidth = expectedBorderWidth
        
        let newButtonStyle = AdyenButtonStyles(colorScheme: .init(primary: .yellow))
        
        // When
        var updatedTheme = theme.textfield(newTextFieldStyle)
        updatedTheme = updatedTheme.button(newButtonStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.backgroundColor, AdyenColorScheme.default.primary)
        XCTAssertEqual(updatedTheme.textFieldStyle.textColor, AdyenColorScheme.default.textOnPrimary)
        XCTAssertEqual(updatedTheme.textFieldStyle.activeColor, AdyenColorScheme.default.highlight)
        XCTAssertEqual(updatedTheme.textFieldStyle.errorColor, AdyenColorScheme.default.textOnDestructive)
        XCTAssertEqual(updatedTheme.textFieldStyle.borderColor, AdyenColorScheme.default.outline)
        XCTAssertEqual(updatedTheme.textFieldStyle.cornerRadius, cornerRadius)
        XCTAssertEqual(updatedTheme.textFieldStyle.borderWidth, expectedBorderWidth)
        XCTAssertEqual(updatedTheme.buttonStyles.primary.backgroundColor, .yellow)
    }
}
