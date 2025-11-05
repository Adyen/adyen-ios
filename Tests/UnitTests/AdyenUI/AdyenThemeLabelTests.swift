//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class AdyenThemeLabelTests: XCTestCase {
    
    func test_defaultTheme_shouldUseDefaultLabelStyles() {
        // Given
        let defaultTheme = AdyenTheme()
        
        // Then
        expect(defaultTheme.elements.labels.body, toMatch: AdyenLabelStyles.default.body)
        expect(defaultTheme.elements.labels.title, toMatch: AdyenLabelStyles.default.title)
        expect(defaultTheme.elements.labels.subtitle, toMatch: AdyenLabelStyles.default.subtitle)
    }

    func test_customTheme_withCustomLabelStyles_shouldUseProvidedValues() {
        // Given
        let customBodyLabel = AdyenLabelStyle(
            font: .systemFont(ofSize: 18, weight: .bold),
            color: .red
        )
        let customTitleLabel = AdyenLabelStyle(
            font: .systemFont(ofSize: 42),
            color: .blue
        )
        
        let customLabels = AdyenLabelStyles(
            title: customTitleLabel,
            body: customBodyLabel
        )
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(labels: customLabels)
        )
        
        // Then
        expect(theme.elements.labels.body, toMatch: customBodyLabel)
        expect(theme.elements.labels.title, toMatch: customTitleLabel)
        expect(theme.elements.labels.subtitle, toMatch: AdyenLabelStyles.default.subtitle)
    }
    
    func test_customTheme_withCustomLabelColor_shouldPreserveOtherProperties() {
        // Given
        let expectedColor = UIColor.red
        let customLabel = AdyenLabelStyle(font: AdyenFonts.default.body, color: expectedColor)
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(
                labels: AdyenLabelStyles(body: customLabel)
            )
        )
        
        // Then
        XCTAssertEqual(theme.elements.labels.body.color, expectedColor)
        XCTAssertEqual(theme.elements.labels.body.font, AdyenLabelStyles.default.body.font)
        XCTAssertEqual(theme.elements.labels.body.textAlignment, AdyenLabelStyles.default.body.textAlignment)
    }
    
    func test_customTheme_withCustomLabelFont_shouldPreserveOtherProperties() {
        // Given
        let expectedFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        let customLabelStyle = AdyenLabelStyle(font: expectedFont)
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(
                labels: AdyenLabelStyles(body: customLabelStyle)
            )
        )
        
        // Then
        XCTAssertEqual(theme.elements.labels.body.font, expectedFont)
        XCTAssertEqual(theme.elements.labels.body.color, AdyenLabelStyles.default.body.color)
        XCTAssertEqual(theme.elements.labels.body.textAlignment, AdyenLabelStyles.default.body.textAlignment)
    }
    
    func test_customTheme_withCustomLabelDisabledColor_shouldPreserveOtherProperties() {
        // Given
        let expectedDisabledColor = UIColor.gray
        let customLabel = AdyenLabelStyle(font: AdyenFonts.default.body, disabledColor: expectedDisabledColor)
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(
                labels: AdyenLabelStyles(body: customLabel)
            )
        )
        
        // Then
        XCTAssertEqual(theme.elements.labels.body.disabledColor, expectedDisabledColor)
        XCTAssertEqual(theme.elements.labels.body.font, AdyenLabelStyles.default.body.font)
        XCTAssertEqual(theme.elements.labels.body.color, AdyenLabelStyles.default.body.color)
    }
    
    func test_customTheme_withCustomLabelTextAlignment_shouldPreserveOtherProperties() {
        // Given
        let expectedTextAlignment: NSTextAlignment = .center
        let customLabel = AdyenLabelStyle(font: AdyenFonts.default.body, textAlignment: expectedTextAlignment)
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(
                labels: AdyenLabelStyles(body: customLabel)
            )
        )
        
        // Then
        XCTAssertEqual(theme.elements.labels.body.textAlignment, expectedTextAlignment)
        XCTAssertEqual(theme.elements.labels.body.font, AdyenLabelStyles.default.body.font)
        XCTAssertEqual(theme.elements.labels.body.color, AdyenLabelStyles.default.body.color)
    }
    
    func test_customTheme_withCustomLabelStyles_shouldPreserveDefaultButtonStyles() {
        // Given
        let customLabel = AdyenLabelStyle(font: AdyenFonts.default.body, color: .red)
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(
                labels: AdyenLabelStyles(body: customLabel)
            )
        )
        
        // Then
        expect(theme.elements.buttons, toMatch: AdyenButtonStyles.default)
        expect(theme.elements.labels.body, toMatch: customLabel)
    }
    
    func test_customTheme_withCustomLabelStyles_shouldPreserveDefaultToggleStyle() {
        // Given
        let customLabel = AdyenLabelStyle(font: AdyenFonts.default.body, color: .red)
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(
                labels: AdyenLabelStyles(body: customLabel)
            )
        )
        
        // Then
        expect(theme.elements.switch, toMatch: AdyenSwitchStyle.default)
        expect(theme.elements.labels.body, toMatch: customLabel)
    }
    
    func test_customTheme_withCustomLabelStyles_shouldPreserveDefaultTextFieldStyle() {
        // Given
        let customLabel = AdyenLabelStyle(font: AdyenFonts.default.body, color: .red)
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(
                labels: AdyenLabelStyles(body: customLabel)
            )
        )
        
        // Then
        expect(theme.elements.textField, toMatch: AdyenTextFieldStyle.default)
        expect(theme.elements.labels.body, toMatch: customLabel)
    }
    
    func test_customTheme_withCustomButtonAndLabelStyles_shouldPreserveBoth() {
        // Given
        let customLabel = AdyenLabelStyle(font: AdyenFonts.default.body, color: .red)
        let customButtonStyle = AdyenButtonStyle(
            backgroundColor: .blue,
            textColor: .white,
            disabledBackgroundColor: .gray,
            disabledTextColor: .lightGray
        )
        
        // When
        let theme = AdyenTheme(
            elements: AdyenElements(
                buttons: AdyenButtonStyles(primary: customButtonStyle),
                labels: AdyenLabelStyles(
                    body: customLabel
                )
            )
        )
        
        // Then
        XCTAssertEqual(theme.elements.buttons.primary, customButtonStyle)
        XCTAssertEqual(theme.elements.labels.body, customLabel)
    }
    
}
