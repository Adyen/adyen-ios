//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class AdyenThemeTests: XCTestCase {
    
    func test_labelMethod_shouldUpdateLabelStyle() {
        // Given
        let theme = AdyenTheme()
        let newLabelStyle = AdyenLabelStyle(color: .red)
        
        // When
        let updatedTheme = theme.label(newLabelStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.labelStyle.color, .red)
    }
    
    func test_buttonMethod_shouldUpdateButtonStyles() {
        // Given
        let theme = AdyenTheme()
        let newButtonStyle = AdyenButtonStyles(colorScheme: .init(primary: .blue))
        
        // When
        let updatedTheme = theme.button(newButtonStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.buttonStyle.primary.backgroundColor, .blue)
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
        let cornerRadius = CornerRounding.fixed(10.0)
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
        let theme = AdyenTheme()
        
        var newTextFieldStyle = AdyenTextFieldStyle()
        
        newTextFieldStyle.borderWidth = 2.0
        
        // When
        let updatedTheme = theme.textfield(newTextFieldStyle)
        
        // Then
        XCTAssertEqual(updatedTheme.textFieldStyle.borderWidth, 2.0)
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
}
