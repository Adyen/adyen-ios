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
        let expectedColorValue = UIColor.red
        let expectedTintColorValue = UIColor.black
        let expectedFontValue: UIFont = .preferredFont(forTextStyle: .footnote)
        let theme = AdyenTheme()
        
        let labelStyle = AdyenLabelStyle().color(expectedColorValue).font(expectedFontValue)
        
        var newToggleStyle = AdyenToggleStyle(title: labelStyle)
        
        newToggleStyle.tintColor = expectedTintColorValue
        
        // When
        let updatedTheme = theme.toggle(newToggleStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.toggleStyle.title.font, expectedFontValue)
        XCTAssertEqual(updatedTheme.toggleStyle.title.color, expectedColorValue)
        XCTAssertEqual(updatedTheme.toggleStyle.tintColor, expectedTintColorValue)
    }
    
    func test_toggleMethod_shouldUpdateToggleTintColor() {
        // Given
        let expectedTintColorValue = UIColor.black
        let theme = AdyenTheme()
        
        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.tintColor = expectedTintColorValue
        
        // When
        let updatedTheme = theme.toggle(newToggleStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.toggleStyle.tintColor, expectedTintColorValue)
    }
    
    func test_toggleMethod_shouldUpdateToggleBackgroundColor() {
        // Given
        let expectedColorValue = UIColor.gray
        let theme = AdyenTheme()
        
        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.backgroundColor = expectedColorValue
        
        // When
        let updatedTheme = theme.toggle(newToggleStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, expectedColorValue)
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
        let expectedColorValue = UIColor.gray
        let theme = AdyenTheme()
    
        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.backgroundColor = expectedColorValue
        
        // When
        let updatedTheme = theme.toggle(newToggleStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.labelStyle.font, AdyenFonts.default.body)
        XCTAssertEqual(updatedTheme.labelStyle.color, AdyenColorScheme.default.primary)
        XCTAssertEqual(updatedTheme.labelStyle.disabledColor, AdyenColorScheme.default.disabled)
        XCTAssertEqual(updatedTheme.labelStyle.textAlignment, .natural)
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, expectedColorValue)
    }
    
    func test_toggleMethod_shouldPreserveDefaultButtonStyle() {
        // Given
        let expectedColorValue = UIColor.gray
        let theme = AdyenTheme()

        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.backgroundColor = expectedColorValue
        
        // When
        let updatedTheme = theme.toggle(newToggleStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.buttonStyles.primary, AdyenButtonStyles.default.primary)
        XCTAssertEqual(updatedTheme.buttonStyles.secondary, AdyenButtonStyles.default.secondary)
        XCTAssertEqual(updatedTheme.buttonStyles.tertiary, AdyenButtonStyles.default.tertiary)
        XCTAssertEqual(updatedTheme.buttonStyles.destructive, AdyenButtonStyles.default.destructive)
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, expectedColorValue)
    }
    
    func test_toggleMethod_shouldPreserveDefaultTextFieldStyle() {
        // Given
        let expectedColorValue = UIColor.gray
        let theme = AdyenTheme()
    
        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.backgroundColor = expectedColorValue
        
        // When
        let updatedTheme = theme.toggle(newToggleStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.backgroundColor, AdyenColorScheme.default.background)
        XCTAssertEqual(updatedTheme.textFieldStyle.activeColor, AdyenColorScheme.default.highlight)
        XCTAssertEqual(updatedTheme.textFieldStyle.errorColor, AdyenColorScheme.default.destructive)
        XCTAssertEqual(updatedTheme.textFieldStyle.cornerRadius, CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius))
        XCTAssertEqual(updatedTheme.textFieldStyle.borderColor, AdyenColorScheme.default.outline)
        XCTAssertEqual(updatedTheme.textFieldStyle.borderWidth, AdyenUIConstants.defaultBorderWidth)
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, expectedColorValue)
    }
    
    func test_toggleMethod_shouldPreserveUpdatedLabelStyle() {
        // Given
        let expectedColorValue = UIColor.red
        let expectedToggleBackgroundColorValue = UIColor.systemPink
        let expectedFontValue: UIFont = .preferredFont(forTextStyle: .caption2)
        let theme = AdyenTheme()

        let newLabelStyle = AdyenLabelStyle(color: expectedColorValue).font(expectedFontValue)
        
        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.backgroundColor = expectedToggleBackgroundColorValue
        
        // When
        var updatedTheme = theme.label(newLabelStyle)
        updatedTheme = updatedTheme.toggle(newToggleStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.labelStyle.font, expectedFontValue)
        XCTAssertEqual(updatedTheme.labelStyle.color, expectedColorValue)
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, expectedToggleBackgroundColorValue)
    }
    
    func test_toggleMethod_shouldPreserveUpdatedButtonStyle() {
        // Given
        let expectedColorValue = UIColor.blue
        let expectedToggleBackgroundColorValue = UIColor.systemPink
        let theme = AdyenTheme()
    
        let newButtonStyle = AdyenButtonStyles(colorScheme: .init(primary: expectedColorValue))
        
        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.backgroundColor = expectedToggleBackgroundColorValue
        
        // When
        var updatedTheme = theme.button(newButtonStyle)
        updatedTheme = updatedTheme.toggle(newToggleStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.buttonStyles.primary.backgroundColor, expectedColorValue)
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, expectedToggleBackgroundColorValue)
    }
    
    func test_toggleMethod_shouldPreserveUpdatedTextFieldStyle() {
        // Given
        let expectedBorderWidth: CGFloat = 2.0
        let expectedCornerRadius: CGFloat = 10.0
        let expectedToggleBackgroundColorValue = UIColor.systemPink
        let expectedTextFieldBackgroundColorValue = UIColor.gray
        let expectedTextFieldActiveColorValue = UIColor.green
        let expectedTextFieldErrorColorValue = UIColor.red
        let expectedTextFieldBorderColorValue = UIColor.black
        let cornerRadius = CornerRounding.fixed(expectedCornerRadius)
        let theme = AdyenTheme()
        
        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.backgroundColor = expectedToggleBackgroundColorValue
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.backgroundColor = expectedTextFieldBackgroundColorValue
        newTextFieldStyle.activeColor = expectedTextFieldActiveColorValue
        newTextFieldStyle.errorColor = expectedTextFieldErrorColorValue
        newTextFieldStyle.borderColor = expectedTextFieldBorderColorValue
        newTextFieldStyle.cornerRadius = cornerRadius
        newTextFieldStyle.borderWidth = expectedBorderWidth
        
        // When
        var updatedTheme = theme.textfield(newTextFieldStyle)
        updatedTheme = updatedTheme.toggle(newToggleStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.backgroundColor, expectedTextFieldBackgroundColorValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.activeColor, expectedTextFieldActiveColorValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.errorColor, expectedTextFieldErrorColorValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.borderColor, expectedTextFieldBorderColorValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.cornerRadius, cornerRadius)
        XCTAssertEqual(updatedTheme.textFieldStyle.borderWidth, expectedBorderWidth)
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, expectedToggleBackgroundColorValue)
    }
}
