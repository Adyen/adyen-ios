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
        let expectedColorValue = UIColor.red
        let theme = AdyenTheme()
        
        let newLabelStyle = AdyenLabelStyle(color: expectedColorValue)
        
        // When
        let updatedTheme = theme.label(newLabelStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.labelStyle.color, expectedColorValue)
    }
    
    func test_labelMethod_shouldUpdateLabelFont() {
        // Given
        let expectedFontValue: UIFont = .preferredFont(forTextStyle: .body)
        let theme = AdyenTheme()
        
        let newLabelStyle = AdyenLabelStyle(font: expectedFontValue)
        
        // When
        let updatedTheme = theme.label(newLabelStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.labelStyle.font, expectedFontValue)
    }
    
    func test_labelMethod_shouldUpdateLabelDisabledColor() {
        // Given
        let expectedColorValue = UIColor.gray
        let theme = AdyenTheme()
    
        let newLabelStyle = AdyenLabelStyle(disabledColor: expectedColorValue)
        
        // When
        let updatedTheme = theme.label(newLabelStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.labelStyle.disabledColor, expectedColorValue)
    }
    
    func test_labelMethod_shouldUpdateLabelTextAlignment() {
        // Given
        let expectedTextAlignment: NSTextAlignment = .left
        let theme = AdyenTheme()

        let newLabelStyle = AdyenLabelStyle(textAlignment: expectedTextAlignment)
        
        // When
        let updatedTheme = theme.label(newLabelStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.labelStyle.textAlignment, expectedTextAlignment)
    }
    
    func test_labelMethod_shouldPreserveDefaultButtonStyle() {
        // Given
        let expectedTextAlignment: NSTextAlignment = .left
        let theme = AdyenTheme()
    
        let newLabelStyle = AdyenLabelStyle(textAlignment: expectedTextAlignment)
        
        // When
        let updatedTheme = theme.label(newLabelStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.buttonStyles.primary, AdyenButtonStyles.default.primary)
        XCTAssertEqual(updatedTheme.buttonStyles.secondary, AdyenButtonStyles.default.secondary)
        XCTAssertEqual(updatedTheme.buttonStyles.tertiary, AdyenButtonStyles.default.tertiary)
        XCTAssertEqual(updatedTheme.buttonStyles.destructive, AdyenButtonStyles.default.destructive)
        XCTAssertEqual(updatedTheme.labelStyle.textAlignment, expectedTextAlignment)
    }
    
    func test_labelMethod_shouldPreserveDefaultToggleStyle() {
        // Given
        let expectedColorValue = UIColor.red
        let theme = AdyenTheme()
    
        let newLabelStyle = AdyenLabelStyle(color: expectedColorValue)
        
        // When
        let updatedTheme = theme.label(newLabelStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.toggleStyle.title.font, AdyenLabelStyle().font)
        XCTAssertEqual(updatedTheme.toggleStyle.title.color, AdyenLabelStyle().color)
        XCTAssertEqual(updatedTheme.toggleStyle.tintColor, nil)
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, .clear)
        XCTAssertEqual(updatedTheme.toggleStyle.cornerRadius, CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius))
        XCTAssertEqual(updatedTheme.labelStyle.color, expectedColorValue)
    }
    
    func test_labelMethod_shouldPreserveDefaultTextFieldStyle() {
        // Given
        let expectedTextAlignment: NSTextAlignment = .left
        let theme = AdyenTheme()
        
        let newLabelStyle = AdyenLabelStyle(textAlignment: expectedTextAlignment)
        
        // When
        let updatedTheme = theme.label(newLabelStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.backgroundColor, AdyenColorScheme.default.background)
        XCTAssertEqual(updatedTheme.textFieldStyle.activeColor, AdyenColorScheme.default.highlight)
        XCTAssertEqual(updatedTheme.textFieldStyle.errorColor, AdyenColorScheme.default.destructive)
        XCTAssertEqual(updatedTheme.textFieldStyle.cornerRadius, CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius))
        XCTAssertEqual(updatedTheme.textFieldStyle.borderColor, AdyenColorScheme.default.outline)
        XCTAssertEqual(updatedTheme.textFieldStyle.borderWidth, AdyenUIConstants.defaultBorderWidth)
        XCTAssertEqual(updatedTheme.labelStyle.textAlignment, expectedTextAlignment)
    }
    
    func test_labelMethod_shouldPreserveUpdatedButtonStyle() {
        // Given
        let expectedColorValue = UIColor.red
        let expectedButtonBackgroundColorValue = UIColor.blue
        let expectedFontValue: UIFont = .preferredFont(forTextStyle: .body)
        let theme = AdyenTheme()
    
        let newLabelStyle = AdyenLabelStyle(color: expectedColorValue).font(expectedFontValue)
        
        let newButtonStyle = AdyenButtonStyles(colorScheme: .init(primary: expectedButtonBackgroundColorValue))
        
        // When
        var updatedTheme = theme.button(newButtonStyle)
        updatedTheme = updatedTheme.label(newLabelStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.buttonStyles.primary.backgroundColor, expectedButtonBackgroundColorValue)
        XCTAssertEqual(updatedTheme.labelStyle.font, expectedFontValue)
        XCTAssertEqual(updatedTheme.labelStyle.color, expectedColorValue)
    }
    
    func test_labelMethod_shouldPreserveUpdatedToggleStyle() {
        // Given
        let theme = AdyenTheme()
        let expectedToggleBackgroundColorValue = UIColor.systemOrange
        let expectedLabelColorValue = UIColor.red
        let expectedTintValue = UIColor.systemPink
        let expectedCornerRadius = 12.0
        let expectedFont: UIFont = .preferredFont(forTextStyle: .body)
    
        let labelStyle = AdyenLabelStyle().color(expectedLabelColorValue).font(expectedFont)

        var newToggleStyle = AdyenToggleStyle()
        newToggleStyle.backgroundColor = expectedToggleBackgroundColorValue
        newToggleStyle.tintColor = expectedTintValue
        newToggleStyle.title = labelStyle
        newToggleStyle.cornerRadius = CornerRounding.fixed(expectedCornerRadius)
        
        // When
        var updatedTheme = theme.toggle(newToggleStyle)
        updatedTheme = updatedTheme.label(labelStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.toggleStyle.backgroundColor, expectedToggleBackgroundColorValue)
        XCTAssertEqual(updatedTheme.toggleStyle.tintColor, expectedTintValue)
        XCTAssertEqual(updatedTheme.toggleStyle.title.color, expectedLabelColorValue)
        XCTAssertEqual(updatedTheme.toggleStyle.cornerRadius, CornerRounding.fixed(expectedCornerRadius))
        XCTAssertEqual(updatedTheme.labelStyle.color, expectedLabelColorValue)
        XCTAssertEqual(updatedTheme.labelStyle.font, expectedFont)
    }
    
    func test_labelMethod_shouldPreserveUpdatedTextFieldStyle() {
        // Given
        let expectedBorderWidth: CGFloat = 2.0
        let expectedCornerRadius: CGFloat = 10.0
        let expectedBackgroundColorValue = UIColor.red
        let expectedActiveColorValue = UIColor.green
        let expectedLabelColorValue = UIColor.brown
        let expectedErrorColorValue = UIColor.purple
        let expectedBorderColorValue = UIColor.brown
        let expectedFont: UIFont = .preferredFont(forTextStyle: .body)
        let cornerRadius = CornerRounding.fixed(expectedCornerRadius)
        let theme = AdyenTheme()
    
        var newTextFieldStyle = AdyenTextFieldStyle()
        newTextFieldStyle.backgroundColor = expectedBackgroundColorValue
        newTextFieldStyle.activeColor = expectedActiveColorValue
        newTextFieldStyle.errorColor = expectedErrorColorValue
        newTextFieldStyle.borderColor = expectedBorderColorValue
        newTextFieldStyle.cornerRadius = cornerRadius
        newTextFieldStyle.borderWidth = expectedBorderWidth
        
        let labelStyle = AdyenLabelStyle().color(expectedLabelColorValue).font(expectedFont)
        
        // When
        var updatedTheme = theme.textfield(newTextFieldStyle)
        updatedTheme = updatedTheme.label(labelStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.backgroundColor, expectedBackgroundColorValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.activeColor, expectedActiveColorValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.errorColor, expectedErrorColorValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.borderColor, expectedBorderColorValue)
        XCTAssertEqual(updatedTheme.textFieldStyle.cornerRadius, cornerRadius)
        XCTAssertEqual(updatedTheme.textFieldStyle.borderWidth, expectedBorderWidth)
        XCTAssertEqual(updatedTheme.labelStyle.color, expectedLabelColorValue)
        XCTAssertEqual(updatedTheme.labelStyle.font, expectedFont)
    }
    
}
