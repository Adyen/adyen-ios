//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class AdyenThemeInitializerTests: XCTestCase {
    
    func test_defaultInitialization_shouldUseDefaultValues() {
        // Given & When
        let theme = AdyenTheme()

        // Then
        XCTAssertEqual(theme.colors, AdyenColors.default)
        XCTAssertEqual(theme.elements.buttons, AdyenButtonStyles.default)
        XCTAssertEqual(theme.elements.labels, AdyenLabelStyles.default)
    }

    func test_partialInitialization_colorsOnly_shouldUseDefaultsForOthers() {
        // Given
        let customColors = AdyenColors(primary: .systemBlue)

        // When
        let theme = AdyenTheme(colors: customColors)

        // Then
        XCTAssertEqual(theme.colors.primary, .systemBlue)
        XCTAssertEqual(theme.elements, AdyenElements.default)
        XCTAssertEqual(theme.attributes, AdyenAttributes.default)
    }

    func test_partialInitialization_elementsOnly_shouldUseDefaultsForOthers() {
        // Given
        let customElements = AdyenElements(
            buttons: AdyenButtonStyles(
                destructive: AdyenButtonStyle(
                    backgroundColor: .red,
                    textColor: .white,
                    disabledBackgroundColor: .gray,
                    disabledTextColor: .lightGray
                )
            )
        )

        // When
        let theme = AdyenTheme(elements: customElements)

        // Then
        XCTAssertEqual(theme.colors, AdyenColors.default)
        XCTAssertEqual(theme.elements.buttons.destructive.backgroundColor, .red)
        XCTAssertEqual(theme.attributes, AdyenAttributes.default)
    }

    func test_fullCustomization_shouldUseAllProvidedValues() {
        // Given
        let customColors = AdyenColors(primary: .blue)
        let customElements = AdyenElements(
            labels: AdyenLabelStyles(
                title: AdyenLabelStyle(font: .systemFont(ofSize: 42), color: .red)
            )
        )
        let customAttributes = AdyenAttributes(cornerRadius: 20)

        // When
        let theme = AdyenTheme(
            colors: customColors,
            elements: customElements,
            attributes: customAttributes
        )

        // Then
        XCTAssertEqual(theme.colors.primary, .blue)
        XCTAssertEqual(theme.elements.labels.title.font, .systemFont(ofSize: 42))
        XCTAssertEqual(theme.attributes.cornerRadius, 20)
    }

    func test_nestedInitialization_matchingDemoExample() {
        // Given & When
        let theme = AdyenTheme(
            colors: AdyenColors(primary: .systemBlue),
            elements: AdyenElements(
                buttons: AdyenButtonStyles(
                    destructive: AdyenButtonStyle(
                        backgroundColor: .systemRed,
                        textColor: .white,
                        disabledBackgroundColor: .systemGray,
                        disabledTextColor: .lightGray
                    )
                ),
                labels: AdyenLabelStyles(
                    body: AdyenLabelStyle(
                        font: AdyenFonts.default.body,
                        color: AdyenColors.default.textOnPrimary
                    )
                )
            )
        )

        // Then
        XCTAssertEqual(theme.colors.primary, .systemBlue)
        XCTAssertEqual(theme.elements.buttons.destructive.backgroundColor, .systemRed)
        XCTAssertEqual(theme.elements.labels.body.color, AdyenColors.default.textOnPrimary)
    }

    func test_valueSemanticsForTheme_modificationCreatesNewInstance() {
        // Given
        let theme1 = AdyenTheme(colors: AdyenColors(primary: .red))

        // When
        let theme2 = AdyenTheme(
            colors: AdyenColors(primary: .blue),
            elements: theme1.elements,
            attributes: theme1.attributes
        )

        // Then
        XCTAssertNotEqual(theme1.colors.primary, theme2.colors.primary)
        XCTAssertEqual(theme1.colors.primary, .red)
        XCTAssertEqual(theme2.colors.primary, .blue)
    }

}
