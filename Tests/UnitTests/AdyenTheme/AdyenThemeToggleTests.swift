//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class AdyenThemeToggleTests: XCTestCase {
    
    func test_toggleMethod_defaultTheme() {
        // Given
        let defaultTheme = AdyenTheme()
        
        // Then
        XCTAssertEqual(defaultTheme.toggleStyle.title.font, AdyenLabelStyle().font)
        XCTAssertEqual(defaultTheme.toggleStyle.title.color, AdyenLabelStyle().color)
        XCTAssertEqual(defaultTheme.toggleStyle.tintColor, nil)
        XCTAssertEqual(defaultTheme.toggleStyle.backgroundColor, .clear)
        XCTAssertEqual(defaultTheme.toggleStyle.cornerRadius, CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius))
    }

    func test_toggleMethod_shouldUpdateToggleTitleLabel() {
        // Given
        let theme = AdyenTheme()
        
        let labelStyle = AdyenLabelStyle().color(.red).font(AdyenFonts.default.bodyEmphasized)
        
        var newToggleStyle = AdyenToggleStyle(title: labelStyle)
        
        newToggleStyle.tintColor = .black
        
        // When
        let updatedTheme = theme.toggle(newToggleStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.toggleStyle.title.font, AdyenFonts.default.bodyEmphasized)
        XCTAssertEqual(updatedTheme.toggleStyle.title.color, .red)
        XCTAssertEqual(updatedTheme.toggleStyle.tintColor, .black)
    }
    
    func test_toggleMethod_shouldUpdateToggleTintColor() {
        // Given
        let theme = AdyenTheme()
        
        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.tintColor = .black
        
        // When
        let updatedTheme = theme.toggle(newToggleStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.toggleStyle.tintColor, .black)
    }
    
    func test_toggleMethod_shouldUpdateToggleBackgroundColor() {
        // Given
        let theme = AdyenTheme()
        
        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.backgroundColor = AdyenColorScheme.default.primary
        
        // When
        let updatedTheme = theme.toggle(newToggleStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, AdyenColorScheme.default.primary)
    }
    
    func test_toggleMethod_shouldUpdateToggleCornerRadius() {
        // Given
        let cornerRadius = CornerRounding.fixed(10.0)
        let theme = AdyenTheme()
        
        var newToggleStyle = AdyenToggleStyle()
        
        newToggleStyle.cornerRadius = cornerRadius
        
        // When
        let updatedTheme = theme.toggle(newToggleStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.toggleStyle.cornerRadius, cornerRadius)
    }
    
    func test_toggleMethod_shouldPreserveDefaultLabelStyle() {
        // Given
        let theme = AdyenTheme()
        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.backgroundColor = AdyenColorScheme.default.primary
        
        // When
        let updatedTheme = theme.toggle(newToggleStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.labelStyle.font, AdyenFonts.default.body)
        XCTAssertEqual(updatedTheme.labelStyle.color, AdyenColorScheme.default.primary)
        XCTAssertEqual(updatedTheme.labelStyle.disabledColor, AdyenColorScheme.default.disabled)
        XCTAssertEqual(updatedTheme.labelStyle.textAlignment, .natural)
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, AdyenColorScheme.default.primary)
    }
    
    func test_toggleMethod_shouldPreserveDefaultButtonStyle() {
        // Given
        let theme = AdyenTheme()
        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.backgroundColor = AdyenColorScheme.default.primary
        
        // When
        let updatedTheme = theme.toggle(newToggleStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.buttonStyles.primary, AdyenButtonStyles.default.primary)
        XCTAssertEqual(updatedTheme.buttonStyles.secondary, AdyenButtonStyles.default.secondary)
        XCTAssertEqual(updatedTheme.buttonStyles.tertiary, AdyenButtonStyles.default.tertiary)
        XCTAssertEqual(updatedTheme.buttonStyles.destructive, AdyenButtonStyles.default.destructive)
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, AdyenColorScheme.default.primary)
    }
    
    func test_toggleMethod_shouldPreserveDefaultTextFieldStyle() {
        // Given
        let theme = AdyenTheme()
        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.backgroundColor = AdyenColorScheme.default.primary
        
        // When
        let updatedTheme = theme.toggle(newToggleStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.backgroundColor, AdyenColorScheme.default.background)
        XCTAssertEqual(updatedTheme.textFieldStyle.textColor, AdyenColorScheme.default.text)
        XCTAssertEqual(updatedTheme.textFieldStyle.activeColor, AdyenColorScheme.default.highlight)
        XCTAssertEqual(updatedTheme.textFieldStyle.errorColor, AdyenColorScheme.default.destructive)
        XCTAssertEqual(updatedTheme.textFieldStyle.cornerRadius, CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius))
        XCTAssertEqual(updatedTheme.textFieldStyle.borderColor, AdyenColorScheme.default.outline)
        XCTAssertEqual(updatedTheme.textFieldStyle.borderWidth, AdyenUIConstants.defaultBorderWidth)
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, AdyenColorScheme.default.primary)
    }
    
    func test_toggleMethod_shouldPreserveUpdatedLabelStyle() {
        // Given
        let theme = AdyenTheme()
        let newLabelStyle = AdyenLabelStyle(color: .red).font(AdyenFonts.default.bodyEmphasized)
        
        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.backgroundColor = AdyenColorScheme.default.primary
        
        // When
        var updatedTheme = theme.label(newLabelStyle)
        updatedTheme = updatedTheme.toggle(newToggleStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.labelStyle.font, AdyenFonts.default.bodyEmphasized)
        XCTAssertEqual(updatedTheme.labelStyle.color, .red)
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, AdyenColorScheme.default.primary)
    }
    
    func test_toggleMethod_shouldPreserveUpdatedButtonStyle() {
        // Given
        let theme = AdyenTheme()
        let newButtonStyle = AdyenButtonStyles(colorScheme: .init(primary: .blue))
        
        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.backgroundColor = AdyenColorScheme.default.primary
        
        // When
        var updatedTheme = theme.button(newButtonStyle)
        updatedTheme = updatedTheme.toggle(newToggleStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.buttonStyles.primary.backgroundColor, .blue)
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, AdyenColorScheme.default.primary)
    }
    
    func test_toggleMethod_shouldPreserveUpdatedTextFieldStyle() {
        // Given
        let expectedBorderWidth: CGFloat = 2.0
        let expectedCornerRadius: CGFloat = 10.0
        let cornerRadius = CornerRounding.fixed(expectedCornerRadius)
        let theme = AdyenTheme()
        
        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.backgroundColor = AdyenColorScheme.default.primary
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.backgroundColor = AdyenColorScheme.default.primary
        newTextFieldStyle.textColor = AdyenColorScheme.default.textOnPrimary
        newTextFieldStyle.activeColor = AdyenColorScheme.default.highlight
        newTextFieldStyle.errorColor = AdyenColorScheme.default.textOnDestructive
        newTextFieldStyle.borderColor = AdyenColorScheme.default.outline
        newTextFieldStyle.cornerRadius = cornerRadius
        newTextFieldStyle.borderWidth = expectedBorderWidth
        
        // When
        var updatedTheme = theme.textfield(newTextFieldStyle)
        updatedTheme = updatedTheme.toggle(newToggleStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.backgroundColor, AdyenColorScheme.default.primary)
        XCTAssertEqual(updatedTheme.textFieldStyle.textColor, AdyenColorScheme.default.textOnPrimary)
        XCTAssertEqual(updatedTheme.textFieldStyle.activeColor, AdyenColorScheme.default.highlight)
        XCTAssertEqual(updatedTheme.textFieldStyle.errorColor, AdyenColorScheme.default.textOnDestructive)
        XCTAssertEqual(updatedTheme.textFieldStyle.borderColor, AdyenColorScheme.default.outline)
        XCTAssertEqual(updatedTheme.textFieldStyle.cornerRadius, cornerRadius)
        XCTAssertEqual(updatedTheme.textFieldStyle.borderWidth, expectedBorderWidth)
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, AdyenColorScheme.default.primary)
    }
}
