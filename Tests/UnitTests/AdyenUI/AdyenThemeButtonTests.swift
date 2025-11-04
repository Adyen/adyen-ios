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
        expect(defaultTheme.buttonStyles, toMatch: AdyenButtonStyles())
    }
    
    func test_buttonMethod_shouldUpdateButtonStyles() {
        // Given
        let expectedValue = UIColor.blue
        let theme = AdyenTheme()
        
        let newButtonStyles = AdyenButtonStyles(colorScheme: .init(primary: expectedValue))
        
        // When
        let updatedTheme = theme.button(newButtonStyles)
        
        // Then
        expect(updatedTheme.buttonStyles, toMatch: newButtonStyles)
    }
    
    func test_buttonMethod_shouldPreserveDefaultLabelStyle() {
        // Given
        let expectedValue = UIColor.blue
        let theme = AdyenTheme()
    
        let newButtonStyles = AdyenButtonStyles(colorScheme: .init(primary: expectedValue))
        
        // When
        let updatedTheme = theme.button(newButtonStyles)
        
        // Then
        expect(updatedTheme.labelStyle, toMatch: AdyenLabelStyle())
        expect(updatedTheme.buttonStyles, toMatch: newButtonStyles)
    }
    
    func test_buttonMethod_shouldPreserveDefaultToggleStyle() {
        // Given
        let expectedValue = UIColor.blue
        let theme = AdyenTheme()

        let newButtonStyles = AdyenButtonStyles(colorScheme: .init(primary: expectedValue))
        
        // When
        let updatedTheme = theme.button(newButtonStyles)
        
        // Then
        expect(updatedTheme.toggleStyle, toMatch: AdyenSwitchStyle())
        expect(updatedTheme.buttonStyles, toMatch: newButtonStyles)
    }
    
    func test_buttonMethod_shouldPreserveDefaultTextFieldStyle() {
        // Given
        let expectedValue = UIColor.blue
        let theme = AdyenTheme()

        let newButtonStyles = AdyenButtonStyles(colorScheme: .init(primary: expectedValue))
        
        // When
        let updatedTheme = theme.button(newButtonStyles)
        
        // Then
        expect(updatedTheme.textFieldStyle, toMatch: AdyenTextFieldStyle())
        expect(updatedTheme.buttonStyles, toMatch: newButtonStyles)
    }
    
    func test_buttonMethod_shouldPreserveUpdatedLabelStyle() {
        // Given
        let expectedLabelColorValue = UIColor.red
        let expectedButtonColorValue = UIColor.blue
        let expectedFontValue: UIFont = .preferredFont(forTextStyle: .callout)
        let theme = AdyenTheme()
        
        let newLabelStyle = AdyenLabelStyle(color: expectedLabelColorValue).font(expectedFontValue)
        let newButtonStyles = AdyenButtonStyles(colorScheme: .init(primary: expectedButtonColorValue))
        
        // When
        var updatedTheme = theme.label(newLabelStyle)
        updatedTheme = updatedTheme.button(newButtonStyles)
        
        // Then
        expect(updatedTheme.labelStyle, toMatch: newLabelStyle)
        expect(updatedTheme.buttonStyles, toMatch: newButtonStyles)
    }
    
    func test_buttonMethod_shouldPreserveUpdatedToggleStyle() {
        // Given
        let expectedLabelColorValue = UIColor.gray
        let expectedToggleBackgroundColorValue = UIColor.red
        let expectedButtonBackgroundColorValue = UIColor.red
        let expectedToggleTintColorValue = UIColor.orange
        let expectedFontValue: UIFont = .preferredFont(forTextStyle: .callout)
        let expectedCornerRadiusValue = 16.0
    
        let theme = AdyenTheme()
    
        let labelStyle = AdyenLabelStyle().color(expectedLabelColorValue).font(expectedFontValue)

        var newToggleStyle = AdyenSwitchStyle()
        newToggleStyle.backgroundColor = expectedToggleBackgroundColorValue
        newToggleStyle.tintColor = expectedToggleTintColorValue
        newToggleStyle.title = labelStyle
        newToggleStyle.cornerRadius = CornerRounding.fixed(expectedCornerRadiusValue)
        
        let newButtonStyles = AdyenButtonStyles(colorScheme: .init(primary: expectedButtonBackgroundColorValue))
        
        // When
        var updatedTheme = theme.toggle(newToggleStyle)
        updatedTheme = updatedTheme.button(newButtonStyles)
        
        // Then
        expect(updatedTheme.toggleStyle, toMatch: newToggleStyle)
        expect(updatedTheme.buttonStyles, toMatch: newButtonStyles)
    }
    
    func test_buttonMethod_shouldPreserveUpdatedTextFieldStyle() {
        // Given
        let expectedBorderWidth: CGFloat = 2.0
        let expectedCornerRadius: CGFloat = 10.0
        let cornerRadius = CornerRounding.fixed(expectedCornerRadius)
        let expectedBackgroundColorValue = UIColor.red
        let expectedBorderColorValue = UIColor.cyan
        let expectedErrorColorValue = UIColor.orange

        let theme = AdyenTheme()
    
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.backgroundColor = expectedBackgroundColorValue
        newTextFieldStyle.errorColor = expectedErrorColorValue
        newTextFieldStyle.borderColor = expectedBorderColorValue
        newTextFieldStyle.cornerRadius = cornerRadius
        newTextFieldStyle.borderWidth = expectedBorderWidth
        
        let newButtonStyles = AdyenButtonStyles(colorScheme: .init(primary: expectedBackgroundColorValue))
        
        // When
        var updatedTheme = theme.textfield(newTextFieldStyle)
        updatedTheme = updatedTheme.button(newButtonStyles)
        
        // Then
        expect(updatedTheme.textFieldStyle, toMatch: newTextFieldStyle)
        expect(updatedTheme.buttonStyles, toMatch: newButtonStyles)
    }
}
