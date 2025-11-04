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
        expect(defaultTheme.toggleStyle, toMatch: AdyenSwitchStyle())
    }

    func test_toggleMethod_shouldUpdateToggleTitleLabel() {
        // Given
        let expectedColorValue = UIColor.red
        let expectedTintColorValue = UIColor.black
        let expectedFontValue: UIFont = .preferredFont(forTextStyle: .footnote)
        let theme = AdyenTheme()
        
        let labelStyle = AdyenLabelStyle().color(expectedColorValue).font(expectedFontValue)
        
        var newToggleStyle = AdyenSwitchStyle(title: labelStyle)
        
        newToggleStyle.tintColor = expectedTintColorValue
        
        // When
        let updatedTheme = theme.toggle(newToggleStyle)
        
        // Then
        expect(updatedTheme.toggleStyle, toMatch: newToggleStyle)
    }
    
    func test_toggleMethod_shouldUpdateToggleTintColor() {
        // Given
        let expectedTintColorValue = UIColor.black
        let theme = AdyenTheme()
        
        var newToggleStyle = AdyenSwitchStyle()
        newToggleStyle.tintColor = expectedTintColorValue
        
        // When
        let updatedTheme = theme.toggle(newToggleStyle)
        
        // Then
        expect(updatedTheme.toggleStyle, toMatch: newToggleStyle)
    }
    
    func test_toggleMethod_shouldUpdateToggleBackgroundColor() {
        // Given
        let expectedColorValue = UIColor.gray
        let theme = AdyenTheme()
        
        var newToggleStyle = AdyenSwitchStyle()
        newToggleStyle.backgroundColor = expectedColorValue
        
        // When
        let updatedTheme = theme.toggle(newToggleStyle)
        
        // Then
        expect(updatedTheme.toggleStyle, toMatch: newToggleStyle)
    }
    
    func test_toggleMethod_shouldUpdateToggleCornerRadius() {
        // Given
        let cornerRadius = CornerRounding.fixed(10.0)
        let theme = AdyenTheme()
        
        var newToggleStyle = AdyenSwitchStyle()
        
        newToggleStyle.cornerRadius = cornerRadius
        
        // When
        let updatedTheme = theme.toggle(newToggleStyle)
        
        // Then
        expect(updatedTheme.toggleStyle, toMatch: newToggleStyle)
    }
    
    func test_toggleMethod_shouldPreserveDefaultLabelStyle() {
        // Given
        let expectedColorValue = UIColor.gray
        let theme = AdyenTheme()
    
        var newToggleStyle = AdyenSwitchStyle()
        newToggleStyle.backgroundColor = expectedColorValue
        
        // When
        let updatedTheme = theme.toggle(newToggleStyle)
        
        // Then
        expect(updatedTheme.labelStyle, matches: AdyenLabelStyle(), property: "text")
        expect(updatedTheme.toggleStyle, toMatch: newToggleStyle)
    }
    
    func test_toggleMethod_shouldPreserveDefaultButtonStyle() {
        // Given
        let expectedColorValue = UIColor.gray
        let theme = AdyenTheme()

        var newToggleStyle = AdyenSwitchStyle()
        newToggleStyle.backgroundColor = expectedColorValue
        
        // When
        let updatedTheme = theme.toggle(newToggleStyle)
        
        // Then
        expect(updatedTheme.buttonStyles, toMatch: AdyenButtonStyles())
        expect(updatedTheme.toggleStyle, toMatch: newToggleStyle)
    }
    
    func test_toggleMethod_shouldPreserveDefaultTextFieldStyle() {
        // Given
        let expectedColorValue = UIColor.gray
        let theme = AdyenTheme()
    
        var newToggleStyle = AdyenSwitchStyle()
        newToggleStyle.backgroundColor = expectedColorValue
        
        // When
        let updatedTheme = theme.toggle(newToggleStyle)
        
        // Then
        expect(updatedTheme.textFieldStyle, toMatch: AdyenTextFieldStyle())
        expect(updatedTheme.toggleStyle, toMatch: newToggleStyle)
    }
    
    func test_toggleMethod_shouldPreserveUpdatedLabelStyle() {
        // Given
        let expectedColorValue = UIColor.red
        let expectedToggleBackgroundColorValue = UIColor.systemPink
        let expectedFontValue: UIFont = .preferredFont(forTextStyle: .caption2)
        let theme = AdyenTheme()

        let newLabelStyle = AdyenLabelStyle(color: expectedColorValue).font(expectedFontValue)
        
        var newToggleStyle = AdyenSwitchStyle()
        newToggleStyle.backgroundColor = expectedToggleBackgroundColorValue
        
        // When
        var updatedTheme = theme.label(newLabelStyle)
        updatedTheme = updatedTheme.toggle(newToggleStyle)
        
        // Then
        expect(updatedTheme.labelStyle, matches: newLabelStyle, property: "text")
        expect(updatedTheme.toggleStyle, toMatch: newToggleStyle)
    }
    
    func test_toggleMethod_shouldPreserveUpdatedButtonStyle() {
        // Given
        let expectedColorValue = UIColor.blue
        let expectedToggleBackgroundColorValue = UIColor.systemPink
        let theme = AdyenTheme()
    
        let newButtonStyle = AdyenButtonStyles(colorScheme: .init(primary: expectedColorValue))
        
        var newToggleStyle = AdyenSwitchStyle()
        newToggleStyle.backgroundColor = expectedToggleBackgroundColorValue
        
        // When
        var updatedTheme = theme.button(newButtonStyle)
        updatedTheme = updatedTheme.toggle(newToggleStyle)
        
        // Then
        expect(updatedTheme.buttonStyles, toMatch: newButtonStyle)
        expect(updatedTheme.toggleStyle, toMatch: newToggleStyle)
    }
    
    func test_toggleMethod_shouldPreserveUpdatedTextFieldStyle() {
        // Given
        let expectedBorderWidth: CGFloat = 2.0
        let expectedCornerRadius: CGFloat = 10.0
        let expectedToggleBackgroundColorValue = UIColor.systemPink
        let expectedTextFieldBackgroundColorValue = UIColor.gray
        let expectedTextFieldErrorColorValue = UIColor.red
        let expectedTextFieldBorderColorValue = UIColor.black
        let cornerRadius = CornerRounding.fixed(expectedCornerRadius)
        let theme = AdyenTheme()
        
        var newToggleStyle = AdyenSwitchStyle()
        newToggleStyle.backgroundColor = expectedToggleBackgroundColorValue
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.backgroundColor = expectedTextFieldBackgroundColorValue
        newTextFieldStyle.errorColor = expectedTextFieldErrorColorValue
        newTextFieldStyle.borderColor = expectedTextFieldBorderColorValue
        newTextFieldStyle.cornerRadius = cornerRadius
        newTextFieldStyle.borderWidth = expectedBorderWidth
        
        // When
        var updatedTheme = theme.textfield(newTextFieldStyle)
        updatedTheme = updatedTheme.toggle(newToggleStyle)
        
        // Then
        expect(updatedTheme.textFieldStyle, toMatch: newTextFieldStyle)
        expect(updatedTheme.toggleStyle, toMatch: newToggleStyle)
    }
}
