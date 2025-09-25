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
        let expectedValue = UIColor.blue
        let theme = AdyenTheme()
        let newButtonStyle = AdyenButtonStyles(colorScheme: .init(primary: expectedValue))
        
        // When
        let updatedTheme = theme.button(newButtonStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.buttonStyles.primary.backgroundColor, expectedValue)
    }
    
    func test_buttonMethod_shouldPreserveDefaultLabelStyle() {
        // Given
        let expectedValue = UIColor.blue
        let theme = AdyenTheme()
        let newButtonStyle = AdyenButtonStyles(colorScheme: .init(primary: expectedValue))
        
        // When
        let updatedTheme = theme.button(newButtonStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.labelStyle.font, AdyenFonts.default.body)
        XCTAssertEqual(updatedTheme.labelStyle.color, AdyenColorScheme.default.primary)
        XCTAssertEqual(updatedTheme.labelStyle.disabledColor, AdyenColorScheme.default.disabled)
        XCTAssertEqual(updatedTheme.labelStyle.textAlignment, .natural)
        XCTAssertEqual(updatedTheme.buttonStyles.primary.backgroundColor, expectedValue)
    }
    
    func test_buttonMethod_shouldPreserveDefaultToggleStyle() {
        // Given
        let expectedValue = UIColor.blue
        let theme = AdyenTheme()
        let newButtonStyle = AdyenButtonStyles(colorScheme: .init(primary: expectedValue))
        
        // When
        let updatedTheme = theme.button(newButtonStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.toggleStyle.title.font, AdyenLabelStyle().font)
        XCTAssertEqual(updatedTheme.toggleStyle.title.color, AdyenLabelStyle().color)
        XCTAssertEqual(updatedTheme.toggleStyle.tintColor, nil)
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, .clear)
        XCTAssertEqual(updatedTheme.toggleStyle.cornerRadius, CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius))
        XCTAssertEqual(updatedTheme.buttonStyles.primary.backgroundColor, expectedValue)
    }
    
    func test_buttonMethod_shouldPreserveDefaultTextFieldStyle() {
        // Given
        let expectedValue = UIColor.blue
        let theme = AdyenTheme()
        let newButtonStyle = AdyenButtonStyles(colorScheme: .init(primary: expectedValue))
        
        // When
        let updatedTheme = theme.button(newButtonStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.backgroundColor, AdyenColorScheme.default.background)
        XCTAssertEqual(updatedTheme.textFieldStyle.activeColor, AdyenColorScheme.default.highlight)
        XCTAssertEqual(updatedTheme.textFieldStyle.errorColor, AdyenColorScheme.default.destructive)
        XCTAssertEqual(updatedTheme.textFieldStyle.cornerRadius, CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius))
        XCTAssertEqual(updatedTheme.textFieldStyle.borderColor, AdyenColorScheme.default.outline)
        XCTAssertEqual(updatedTheme.textFieldStyle.borderWidth, AdyenUIConstants.defaultBorderWidth)
        XCTAssertEqual(updatedTheme.buttonStyles.primary.backgroundColor, expectedValue)
    }
    
    func test_buttonMethod_shouldPreserveUpdatedLabelStyle() {
        // Given
        let expectedLabelColorValue = UIColor.red
        let expectedButtonColorValue = UIColor.blue
        let expectedFontValue: UIFont = .preferredFont(forTextStyle: .callout)
        let theme = AdyenTheme()
        
        let newLabelStyle = AdyenLabelStyle(color: expectedLabelColorValue).font(expectedFontValue)
        let newButtonStyle = AdyenButtonStyles(colorScheme: .init(primary: expectedButtonColorValue))
        
        // When
        var updatedTheme = theme.label(newLabelStyle)
        updatedTheme = updatedTheme.button(newButtonStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.labelStyle.font, expectedFontValue)
        XCTAssertEqual(updatedTheme.labelStyle.color, expectedLabelColorValue)
        XCTAssertEqual(updatedTheme.buttonStyles.primary.backgroundColor, expectedButtonColorValue)
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

        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.backgroundColor = expectedToggleBackgroundColorValue
        newToggleStyle.tintColor = expectedToggleTintColorValue
        newToggleStyle.title = labelStyle
        newToggleStyle.cornerRadius = CornerRounding.fixed(expectedCornerRadiusValue)
        
        let newButtonStyle = AdyenButtonStyles(colorScheme: .init(primary: expectedButtonBackgroundColorValue))
        
        // When
        var updatedTheme = theme.toggle(newToggleStyle)
        updatedTheme = updatedTheme.button(newButtonStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, expectedToggleBackgroundColorValue)
        XCTAssertEqual(updatedTheme.toggleStyle.tintColor, expectedToggleTintColorValue)
        XCTAssertEqual(updatedTheme.toggleStyle.title.font, expectedFontValue)
        XCTAssertEqual(updatedTheme.toggleStyle.title.color, expectedLabelColorValue)
        XCTAssertEqual(updatedTheme.toggleStyle.cornerRadius, CornerRounding.fixed(expectedCornerRadiusValue))
        XCTAssertEqual(updatedTheme.buttonStyles.primary.backgroundColor, expectedButtonBackgroundColorValue)
    }
    
    func test_buttonMethod_shouldPreserveUpdatedTextFieldStyle() {
        // Given
        let expectedBorderWidth: CGFloat = 2.0
        let expectedCornerRadius: CGFloat = 10.0
        let cornerRadius = CornerRounding.fixed(expectedCornerRadius)
        let expectedActiveColorValue = UIColor.gray
        let expectedBackgroundColorValue = UIColor.red
        let expectedBorderColorValue = UIColor.cyan
        let expectedErrorColorValue = UIColor.orange

        let theme = AdyenTheme()
    
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.backgroundColor = expectedBackgroundColorValue
        newTextFieldStyle.activeColor = expectedActiveColorValue
        newTextFieldStyle.errorColor = expectedErrorColorValue
        newTextFieldStyle.borderColor = expectedBorderColorValue
        newTextFieldStyle.cornerRadius = cornerRadius
        newTextFieldStyle.borderWidth = expectedBorderWidth
        
        let newButtonStyle = AdyenButtonStyles(colorScheme: .init(primary: expectedBackgroundColorValue))
        
        // When
        var updatedTheme = theme.textfield(newTextFieldStyle)
        updatedTheme = updatedTheme.button(newButtonStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.backgroundColor, expectedBackgroundColorValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.activeColor, expectedActiveColorValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.errorColor, expectedErrorColorValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.borderColor, expectedBorderColorValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.cornerRadius, cornerRadius)
        XCTAssertEqual(updatedTheme.textFieldStyle.borderWidth, expectedBorderWidth)
        XCTAssertEqual(updatedTheme.buttonStyles.primary.backgroundColor, expectedBackgroundColorValue)
    }
}
