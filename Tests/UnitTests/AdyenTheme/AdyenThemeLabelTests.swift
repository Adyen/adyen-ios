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
        expect(defaultTheme.labelStyle, toMatch: AdyenLabelStyle())
    }

    func test_labelMethod_shouldUpdateLabelColor() {
        // Given
        let expectedColorValue = UIColor.red
        let theme = AdyenTheme()
        
        let newLabelStyle = AdyenLabelStyle(color: expectedColorValue)
        
        // When
        let updatedTheme = theme.label(newLabelStyle)
        
        // Then
        expect(updatedTheme.labelStyle, toMatch: newLabelStyle)
    }
    
    func test_labelMethod_shouldUpdateLabelFont() {
        // Given
        let expectedFontValue: UIFont = .preferredFont(forTextStyle: .body)
        let theme = AdyenTheme()
        
        let newLabelStyle = AdyenLabelStyle(font: expectedFontValue)
        
        // When
        let updatedTheme = theme.label(newLabelStyle)
        
        // Then
        expect(updatedTheme.labelStyle, toMatch: newLabelStyle)
    }
    
    func test_labelMethod_shouldUpdateLabelDisabledColor() {
        // Given
        let expectedColorValue = UIColor.gray
        let theme = AdyenTheme()
    
        let newLabelStyle = AdyenLabelStyle(disabledColor: expectedColorValue)
        
        // When
        let updatedTheme = theme.label(newLabelStyle)
        
        // Then
        expect(updatedTheme.labelStyle, toMatch: newLabelStyle)
    }
    
    func test_labelMethod_shouldUpdateLabelTextAlignment() {
        // Given
        let expectedTextAlignment: NSTextAlignment = .left
        let theme = AdyenTheme()

        let newLabelStyle = AdyenLabelStyle(textAlignment: expectedTextAlignment)
        
        // When
        let updatedTheme = theme.label(newLabelStyle)
        
        // Then
        expect(updatedTheme.labelStyle, toMatch: newLabelStyle)
    }
    
    func test_labelMethod_shouldPreserveDefaultButtonStyle() {
        // Given
        let expectedTextAlignment: NSTextAlignment = .left
        let theme = AdyenTheme()
    
        let newLabelStyle = AdyenLabelStyle(textAlignment: expectedTextAlignment)
        
        // When
        let updatedTheme = theme.label(newLabelStyle)
        
        // Then
        expect(updatedTheme.buttonStyles, toMatch: AdyenButtonStyles())
        expect(updatedTheme.labelStyle, toMatch: newLabelStyle)
    }
    
    func test_labelMethod_shouldPreserveDefaultToggleStyle() {
        // Given
        let expectedColorValue = UIColor.red
        let theme = AdyenTheme()
    
        let newLabelStyle = AdyenLabelStyle(color: expectedColorValue)
        
        // When
        let updatedTheme = theme.label(newLabelStyle)
        
        // Then
        expect(updatedTheme.toggleStyle, toMatch: AdyenToggleStyle())
        expect(updatedTheme.labelStyle, toMatch: newLabelStyle)
    }
    
    func test_labelMethod_shouldPreserveDefaultTextFieldStyle() {
        // Given
        let expectedTextAlignment: NSTextAlignment = .left
        let theme = AdyenTheme()
        
        let newLabelStyle = AdyenLabelStyle(textAlignment: expectedTextAlignment)
        
        // When
        let updatedTheme = theme.label(newLabelStyle)
        
        // Then
        expect(updatedTheme.textFieldStyle, toMatch: AdyenTextFieldStyle())
        expect(updatedTheme.labelStyle, toMatch: newLabelStyle)
    }
    
    func test_labelMethod_shouldPreserveUpdatedButtonStyle() {
        // Given
        let expectedColorValue = UIColor.red
        let expectedButtonBackgroundColorValue = UIColor.blue
        let expectedFontValue: UIFont = .preferredFont(forTextStyle: .body)
        let theme = AdyenTheme()
    
        let newLabelStyle = AdyenLabelStyle(color: expectedColorValue).font(expectedFontValue)
        
        let newButtonStyles = AdyenButtonStyles(colorScheme: .init(primary: expectedButtonBackgroundColorValue))
        
        // When
        var updatedTheme = theme.button(newButtonStyles)
        updatedTheme = updatedTheme.label(newLabelStyle)
        
        // Then
        expect(updatedTheme.buttonStyles, toMatch: newButtonStyles)
        expect(updatedTheme.labelStyle, toMatch: newLabelStyle)
    }
    
    func test_labelMethod_shouldPreserveUpdatedToggleStyle() {
        // Given
        let theme = AdyenTheme()
        let expectedToggleBackgroundColorValue = UIColor.systemOrange
        let expectedLabelColorValue = UIColor.red
        let expectedTintValue = UIColor.systemPink
        let expectedCornerRadius = 12.0
        let expectedFont: UIFont = .preferredFont(forTextStyle: .body)
    
        let newLabelStyle = AdyenLabelStyle().color(expectedLabelColorValue).font(expectedFont)

        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.backgroundColor = expectedToggleBackgroundColorValue
        newToggleStyle.tintColor = expectedTintValue
        newToggleStyle.title = newLabelStyle
        newToggleStyle.cornerRadius = CornerRounding.fixed(expectedCornerRadius)
        
        // When
        var updatedTheme = theme.toggle(newToggleStyle)
        updatedTheme = updatedTheme.label(newLabelStyle)
        
        // Then
        expect(updatedTheme.toggleStyle, toMatch: newToggleStyle)
        expect(updatedTheme.labelStyle, toMatch: newLabelStyle)
    }
    
    func test_labelMethod_shouldPreserveUpdatedTextFieldStyle() {
        // Given
        let expectedBorderWidth: CGFloat = 2.0
        let expectedCornerRadius: CGFloat = 10.0
        let expectedBackgroundColorValue = UIColor.red
        let expectedLabelColorValue = UIColor.brown
        let expectedErrorColorValue = UIColor.purple
        let expectedBorderColorValue = UIColor.brown
        let expectedFont: UIFont = .preferredFont(forTextStyle: .body)
        let cornerRadius = CornerRounding.fixed(expectedCornerRadius)
        let theme = AdyenTheme()
    
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.backgroundColor = expectedBackgroundColorValue
        newTextFieldStyle.errorColor = expectedErrorColorValue
        newTextFieldStyle.borderColor = expectedBorderColorValue
        newTextFieldStyle.cornerRadius = cornerRadius
        newTextFieldStyle.borderWidth = expectedBorderWidth
        
        let labelStyle = AdyenLabelStyle().color(expectedLabelColorValue).font(expectedFont)
        
        // When
        var updatedTheme = theme.textfield(newTextFieldStyle)
        updatedTheme = updatedTheme.label(labelStyle)
        
        // Then
        expect(updatedTheme.textFieldStyle, toMatch: newTextFieldStyle)
        expect(updatedTheme.labelStyle, toMatch: labelStyle)
    }
    
}
