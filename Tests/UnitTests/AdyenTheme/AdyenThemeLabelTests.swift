//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class AdyenThemeLabelTests: XCTestCase {
    
    func test_labelMethod_defaultTheme() {
        // Given
        let defaultTheme = AdyenTheme()
        
        // Then
        XCTAssertEqual(defaultTheme.labelStyle.font, AdyenFonts.default.body)
        XCTAssertEqual(defaultTheme.labelStyle.color, AdyenColorScheme.default.primary)
        XCTAssertEqual(defaultTheme.labelStyle.disabledColor, AdyenColorScheme.default.disabled)
        XCTAssertEqual(defaultTheme.labelStyle.textAlignment, .natural)
    }

    func test_labelMethod_shouldUpdateLabelColor() {
        // Given
        let theme = AdyenTheme()
        let newLabelStyle = AdyenLabelStyle(color: .red)
        
        // When
        let updatedTheme = theme.label(newLabelStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.labelStyle.color, .red)
    }
    
    func test_labelMethod_shouldUpdateLabelFont() {
        // Given
        let theme = AdyenTheme()
        let newLabelStyle = AdyenLabelStyle(font: AdyenFonts.default.title)
        
        // When
        let updatedTheme = theme.label(newLabelStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.labelStyle.font, AdyenFonts.default.title)
    }
    
    func test_labelMethod_shouldUpdateLabelDisabledColor() {
        // Given
        let theme = AdyenTheme()
        let newLabelStyle = AdyenLabelStyle(disabledColor: .gray)
        
        // When
        let updatedTheme = theme.label(newLabelStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.labelStyle.disabledColor, .gray)
    }
    
    func test_labelMethod_shouldUpdateLabelTextAlignment() {
        // Given
        let theme = AdyenTheme()
        let newLabelStyle = AdyenLabelStyle(textAlignment: .natural)
        
        // When
        let updatedTheme = theme.label(newLabelStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.labelStyle.textAlignment, .natural)
    }
    
    func test_labelMethod_shouldPreserveDefaultButtonStyle() {
        // Given
        let theme = AdyenTheme()
        let newLabelStyle = AdyenLabelStyle(textAlignment: .natural)
        
        // When
        let updatedTheme = theme.label(newLabelStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.buttonStyles.primary, AdyenButtonStyles.default.primary)
        XCTAssertEqual(updatedTheme.buttonStyles.secondary, AdyenButtonStyles.default.secondary)
        XCTAssertEqual(updatedTheme.buttonStyles.tertiary, AdyenButtonStyles.default.tertiary)
        XCTAssertEqual(updatedTheme.buttonStyles.destructive, AdyenButtonStyles.default.destructive)
        XCTAssertEqual(updatedTheme.labelStyle.textAlignment, .natural)
    }
    
    func test_labelMethod_shouldPreserveDefaultToggleStyle() {
        // Given
        let theme = AdyenTheme()
        let newLabelStyle = AdyenLabelStyle(color: .red)
        
        // When
        let updatedTheme = theme.label(newLabelStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.toggleStyle.title.font, AdyenLabelStyle().font)
        XCTAssertEqual(updatedTheme.toggleStyle.title.color, AdyenLabelStyle().color)
        XCTAssertEqual(updatedTheme.toggleStyle.tintColor, nil)
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, .clear)
        XCTAssertEqual(updatedTheme.toggleStyle.cornerRadius, CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius))
        XCTAssertEqual(updatedTheme.labelStyle.color, .red)
    }
    
    func test_labelMethod_shouldPreserveDefaultTextFieldStyle() {
        // Given
        let theme = AdyenTheme()
        let newLabelStyle = AdyenLabelStyle(textAlignment: .natural)
        
        // When
        let updatedTheme = theme.label(newLabelStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.backgroundColor, AdyenColorScheme.default.background)
        XCTAssertEqual(updatedTheme.textFieldStyle.textColor, AdyenColorScheme.default.text)
        XCTAssertEqual(updatedTheme.textFieldStyle.activeColor, AdyenColorScheme.default.highlight)
        XCTAssertEqual(updatedTheme.textFieldStyle.errorColor, AdyenColorScheme.default.destructive)
        XCTAssertEqual(updatedTheme.textFieldStyle.cornerRadius, CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius))
        XCTAssertEqual(updatedTheme.textFieldStyle.borderColor, AdyenColorScheme.default.outline)
        XCTAssertEqual(updatedTheme.textFieldStyle.borderWidth, AdyenUIConstants.defaultBorderWidth)
        XCTAssertEqual(updatedTheme.labelStyle.textAlignment, .natural)
    }
    
    func test_labelMethod_shouldPreserveUpdatedButtonStyle() {
        // Given
        let theme = AdyenTheme()
        let newLabelStyle = AdyenLabelStyle(color: .red).font(AdyenFonts.default.bodyEmphasized)
        
        let newButtonStyle = AdyenButtonStyles(colorScheme: .init(primary: .blue))
        
        // When
        var updatedTheme = theme.button(newButtonStyle)
        updatedTheme = updatedTheme.label(newLabelStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.buttonStyles.primary.backgroundColor, .blue)
        XCTAssertEqual(updatedTheme.labelStyle.font, AdyenFonts.default.bodyEmphasized)
        XCTAssertEqual(updatedTheme.labelStyle.color, .red)
    }
    
    func test_labelMethod_shouldPreserveUpdatedToggleStyle() {
        // Given
        let theme = AdyenTheme()
        let labelStyle = AdyenLabelStyle().color(.red).font(AdyenFonts.default.bodyEmphasized)

        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.backgroundColor = AdyenColorScheme.default.primary
        newToggleStyle.tintColor = AdyenColorScheme.default.highlight
        newToggleStyle.title = labelStyle
        newToggleStyle.cornerRadius = CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius)
        
        // When
        var updatedTheme = theme.toggle(newToggleStyle)
        updatedTheme = updatedTheme.label(labelStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, AdyenColorScheme.default.primary)
        XCTAssertEqual(updatedTheme.toggleStyle.tintColor, AdyenColorScheme.default.highlight)
        XCTAssertEqual(updatedTheme.toggleStyle.title.font, AdyenFonts.default.bodyEmphasized)
        XCTAssertEqual(updatedTheme.toggleStyle.title.color, .red)
        XCTAssertEqual(updatedTheme.toggleStyle.cornerRadius, CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius))
        XCTAssertEqual(updatedTheme.labelStyle.color, .red)
        XCTAssertEqual(updatedTheme.labelStyle.font, AdyenFonts.default.bodyEmphasized)
    }
    
    func test_labelMethod_shouldPreserveUpdatedTextFieldStyle() {
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
        
        let labelStyle = AdyenLabelStyle().color(.red).font(AdyenFonts.default.bodyEmphasized)
        
        // When
        var updatedTheme = theme.textfield(newTextFieldStyle)
        updatedTheme = updatedTheme.label(labelStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.backgroundColor, AdyenColorScheme.default.primary)
        XCTAssertEqual(updatedTheme.textFieldStyle.textColor, AdyenColorScheme.default.textOnPrimary)
        XCTAssertEqual(updatedTheme.textFieldStyle.activeColor, AdyenColorScheme.default.highlight)
        XCTAssertEqual(updatedTheme.textFieldStyle.errorColor, AdyenColorScheme.default.textOnDestructive)
        XCTAssertEqual(updatedTheme.textFieldStyle.borderColor, AdyenColorScheme.default.outline)
        XCTAssertEqual(updatedTheme.textFieldStyle.cornerRadius, cornerRadius)
        XCTAssertEqual(updatedTheme.textFieldStyle.borderWidth, expectedBorderWidth)
        XCTAssertEqual(updatedTheme.labelStyle.color, .red)
        XCTAssertEqual(updatedTheme.labelStyle.font, AdyenFonts.default.bodyEmphasized)
    }
    
}
