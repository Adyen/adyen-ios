//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class AdyenThemeTextFieldTests: XCTestCase {
    
    func test_defaultTheme_shouldUseDefaultTextFieldStyle() {
        // Given
        let defaultTheme = AdyenTheme()
    
        // Then
        expect(defaultTheme.elements.textField, toMatch: AdyenTextFieldStyle.default)
    }

    func test_customTheme_withCustomTextFieldStyle_shouldUseProvidedValues() {
        // Given
        let expectedBackgroundColor = UIColor.green
        var customTextFieldStyle = AdyenTextFieldStyle()
        customTextFieldStyle.backgroundColor = expectedBackgroundColor
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(textField: customTextFieldStyle)
        )
        
        // Then
        XCTAssertEqual(theme.elements.textField.backgroundColor, expectedBackgroundColor)
    }
    
    func test_customTheme_withCustomTextFieldErrorColor_shouldUseProvidedValues() {
        // Given
        let expectedErrorColor = UIColor.red
        var customTextFieldStyle = AdyenTextFieldStyle()
        customTextFieldStyle.errorColor = expectedErrorColor
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(textField: customTextFieldStyle)
        )
        
        // Then
        XCTAssertEqual(theme.elements.textField.errorColor, expectedErrorColor)
    }
    
    func test_customTheme_withCustomTextFieldBorderColor_shouldUseProvidedValues() {
        // Given
        let expectedBorderColor = UIColor.brown
        var customTextFieldStyle = AdyenTextFieldStyle()
        customTextFieldStyle.borderColor = expectedBorderColor
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(textField: customTextFieldStyle)
        )
        
        // Then
        XCTAssertEqual(theme.elements.textField.borderColor, expectedBorderColor)
    }
    
    func test_customTheme_withCustomTextFieldCornerRadius_shouldUseProvidedValues() {
        // Given
        let expectedCornerRadius: CGFloat = 10.0
        let cornerRadius = CornerRounding.fixed(expectedCornerRadius)
        var customTextFieldStyle = AdyenTextFieldStyle()
        customTextFieldStyle.cornerRadius = cornerRadius
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(textField: customTextFieldStyle)
        )
        
        // Then
        XCTAssertEqual(theme.elements.textField.cornerRadius, cornerRadius)
    }
    
    func test_customTheme_withCustomTextFieldBorderWidth_shouldUseProvidedValues() {
        // Given
        let expectedBorderWidth: CGFloat = 2.0
        var customTextFieldStyle = AdyenTextFieldStyle()
        customTextFieldStyle.borderWidth = expectedBorderWidth
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(textField: customTextFieldStyle)
        )
        
        // Then
        XCTAssertEqual(theme.elements.textField.borderWidth, expectedBorderWidth)
    }
    
    func test_customTheme_withCustomTextFieldTitle_shouldUseProvidedValues() {
        // Given
        let expectedFont = UIFont.preferredFont(forTextStyle: .body)
        let expectedColor = UIColor.red
        let customTitleStyle = AdyenLabelStyle(font: expectedFont, color: expectedColor)
        
        var customTextFieldStyle = AdyenTextFieldStyle()
        customTextFieldStyle.title = customTitleStyle
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(textField: customTextFieldStyle)
        )
        
        // Then
        expect(theme.elements.textField.title, matches: customTitleStyle, property: "title")
    }
    
    func test_customTheme_withCustomTextFieldText_shouldUseProvidedValues() {
        // Given
        let expectedFont = UIFont.preferredFont(forTextStyle: .body)
        let expectedColor = UIColor.red
        let customTextStyle = AdyenLabelStyle(font: expectedFont, color: expectedColor)
        
        var customTextFieldStyle = AdyenTextFieldStyle()
        customTextFieldStyle.text = customTextStyle
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(textField: customTextFieldStyle)
        )
        
        // Then
        expect(theme.elements.textField.text, matches: customTextStyle, property: "text")
    }
    
    func test_customTheme_withCustomTextFieldPlaceholder_shouldUseProvidedValues() {
        // Given
        let expectedFont = UIFont.preferredFont(forTextStyle: .body)
        let expectedColor = UIColor.red
        let customPlaceholderStyle = AdyenLabelStyle(font: expectedFont, color: expectedColor)
        
        var customTextFieldStyle = AdyenTextFieldStyle()
        customTextFieldStyle.placeholder = customPlaceholderStyle
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(textField: customTextFieldStyle)
        )
        
        // Then
        expect(theme.elements.textField.placeholder, matches: customPlaceholderStyle, property: "placeholder")
    }
    
    func test_customTheme_withCustomTextFieldStyle_shouldPreserveDefaultToggleStyle() {
        // Given
        let expectedFont = UIFont.preferredFont(forTextStyle: .body)
        let expectedColor = UIColor.red
        let customTextStyle = AdyenLabelStyle(font: expectedFont, color: expectedColor)
        
        var customTextFieldStyle = AdyenTextFieldStyle()
        customTextFieldStyle.text = customTextStyle
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(textField: customTextFieldStyle)
        )
        
        // Then
        expect(theme.elements.switch, toMatch: AdyenSwitchStyle.default)
        expect(theme.elements.textField.text, matches: customTextStyle, property: "text")
    }
    
    func test_customTheme_withCustomTextFieldStyle_shouldPreserveDefaultLabelStyles() {
        // Given
        let expectedErrorColor = UIColor.purple
        var customTextFieldStyle = AdyenTextFieldStyle()
        customTextFieldStyle.errorColor = expectedErrorColor
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(textField: customTextFieldStyle)
        )
        
        // Then
        XCTAssertEqual(theme.elements.labels.body, AdyenLabelStyles.default.body)
        XCTAssertEqual(theme.elements.labels.title, AdyenLabelStyles.default.title)
        XCTAssertEqual(theme.elements.labels.footnote, AdyenLabelStyles.default.footnote)
        XCTAssertEqual(theme.elements.labels.body, AdyenLabelStyles.default.body)

        XCTAssertEqual(theme.elements.textField.errorColor, expectedErrorColor)
    }
    
    func test_customTheme_withCustomTextFieldStyle_shouldPreserveDefaultButtonStyles() {
        // Given
        let expectedFont = UIFont.preferredFont(forTextStyle: .body)
        let expectedColor = UIColor.red
        let customTextStyle = AdyenLabelStyle(font: expectedFont, color: expectedColor)
        
        var customTextFieldStyle = AdyenTextFieldStyle()
        customTextFieldStyle.text = customTextStyle
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(textField: customTextFieldStyle)
        )
        
        // Then
        expect(theme.elements.buttons, toMatch: AdyenButtonStyles.default)
        expect(theme.elements.textField.text, matches: customTextStyle, property: "text")
    }
    
    func test_customTheme_withCustomTextFieldAndToggleStyles_shouldPreserveBoth() {
        // Given
        let expectedFont = UIFont.preferredFont(forTextStyle: .body)
        let expectedColor = UIColor.red
        let expectedToggleBackgroundColor = UIColor.systemOrange
        let expectedTintColor = UIColor.systemPink
        let expectedCornerRadius = 12.0
        
        let customTextStyle = AdyenLabelStyle(font: expectedFont, color: expectedColor)

        var customTextFieldStyle = AdyenTextFieldStyle()
        customTextFieldStyle.text = customTextStyle
        
        var customToggleStyle = AdyenSwitchStyle()
        customToggleStyle.backgroundColor = expectedToggleBackgroundColor
        customToggleStyle.tintColor = expectedTintColor
        customToggleStyle.cornerRadius = CornerRounding.fixed(expectedCornerRadius)
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(
                switch: customToggleStyle,
                textField: customTextFieldStyle
            )
        )
        
        // Then
        expect(theme.elements.switch, toMatch: customToggleStyle)
        expect(theme.elements.textField.text, matches: customTextStyle, property: "text")
    }
    
    func test_customTheme_withCustomTextFieldAndLabelStyles_shouldPreserveBoth() {
        // Given
        let expectedFont = UIFont.preferredFont(forTextStyle: .body)
        let expectedColor = UIColor.red
        let expectedLabelColor = UIColor.brown
        
        let customTextStyle = AdyenLabelStyle(font: expectedFont, color: expectedColor)
        let customLabelStyle = AdyenLabelStyle(
            font: expectedFont,
            color: expectedLabelColor
        )

        var customTextFieldStyle = AdyenTextFieldStyle()
        customTextFieldStyle.text = customTextStyle
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(
                labels: AdyenLabelStyles(body: customLabelStyle),
                textField: customTextFieldStyle
            )
        )
        
        // Then
        expect(theme.elements.labels.body, toMatch: customLabelStyle)
        expect(theme.elements.textField.text, matches: customTextStyle, property: "text")
    }
    
    func test_customTheme_withCustomTextFieldAndButtonStyles_shouldPreserveBoth() {
        // Given
        let expectedFont = UIFont.preferredFont(forTextStyle: .body)
        let expectedColor = UIColor.red
        let expectedButtonBackgroundColor = UIColor.blue
        
        let customTextStyle = AdyenLabelStyle(font: expectedFont, color: expectedColor)
        
        var customTextFieldStyle = AdyenTextFieldStyle()
        customTextFieldStyle.text = customTextStyle
        
        let customButtonStyle = AdyenButtonStyle(
            backgroundColor: expectedButtonBackgroundColor,
            textColor: .white,
            disabledBackgroundColor: .gray,
            disabledTextColor: .lightGray
        )
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(
                buttons: AdyenButtonStyles(primary: customButtonStyle),
                textField: customTextFieldStyle
            )
        )
        
        // Then
        XCTAssertEqual(theme.elements.buttons.primary, customButtonStyle)
        expect(theme.elements.textField.text, matches: customTextStyle, property: "text")
    }
}
