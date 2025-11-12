//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class AdyenButtonStylesInitializerTests: XCTestCase {
    
    func test_defaultInitialization_shouldUseDefaultStyles() {
        // Given & When
        let styles = AdyenButtonStyles()

        // Then
        XCTAssertEqual(styles.primary, .primary(for: .default))
        XCTAssertEqual(styles.secondary, .secondary(for: .default))
        XCTAssertEqual(styles.tertiary, .tertiary(for: .default))
        XCTAssertEqual(styles.destructive, .destructive(for: .default))
    }

    func test_partialOverride_onlyDestructive_shouldUseDefaultsForOthers() {
        // Given
        let customDestructive = AdyenButtonStyle(
            backgroundColor: .red,
            textColor: .white,
            disabledBackgroundColor: .gray,
            disabledTextColor: .lightGray
        )

        // When
        let styles = AdyenButtonStyles(destructive: customDestructive)

        // Then
        XCTAssertEqual(styles.destructive, customDestructive)
        XCTAssertEqual(styles.primary, .primary(for: .default))
        XCTAssertEqual(styles.secondary, .secondary(for: .default))
        XCTAssertEqual(styles.tertiary, .tertiary(for: .default))
    }

    func test_multipleOverrides_primaryAndSecondary_shouldPreserveOthers() {
        // Given
        let customPrimary = AdyenButtonStyle(
            backgroundColor: .blue,
            textColor: .white,
            disabledBackgroundColor: .gray,
            disabledTextColor: .lightGray
        )
        let customSecondary = AdyenButtonStyle(
            backgroundColor: .green,
            textColor: .black,
            disabledBackgroundColor: .gray,
            disabledTextColor: .lightGray
        )

        // When
        let styles = AdyenButtonStyles(
            primary: customPrimary,
            secondary: customSecondary
        )

        // Then
        XCTAssertEqual(styles.primary, customPrimary)
        XCTAssertEqual(styles.secondary, customSecondary)
        XCTAssertEqual(styles.tertiary, .tertiary(for: .default))
        XCTAssertEqual(styles.destructive, .destructive(for: .default))
    }

    func test_allCustomButtons_shouldUseAllProvidedValues() {
        // Given
        let customPrimary = AdyenButtonStyle(
            backgroundColor: .blue, textColor: .white,
            disabledBackgroundColor: .gray, disabledTextColor: .lightGray
        )
        let customSecondary = AdyenButtonStyle(
            backgroundColor: .green, textColor: .black,
            disabledBackgroundColor: .gray, disabledTextColor: .lightGray
        )
        let customTertiary = AdyenButtonStyle(
            backgroundColor: .clear, textColor: .blue,
            disabledBackgroundColor: .gray, disabledTextColor: .lightGray
        )
        let customDestructive = AdyenButtonStyle(
            backgroundColor: .red, textColor: .white,
            disabledBackgroundColor: .gray, disabledTextColor: .lightGray
        )

        // When
        let styles = AdyenButtonStyles(
            primary: customPrimary,
            secondary: customSecondary,
            tertiary: customTertiary,
            destructive: customDestructive
        )

        // Then
        XCTAssertEqual(styles.primary, customPrimary)
        XCTAssertEqual(styles.secondary, customSecondary)
        XCTAssertEqual(styles.tertiary, customTertiary)
        XCTAssertEqual(styles.destructive, customDestructive)
    }

    func test_valueSemanticsForButtonStyles_modificationCreatesNewInstance() {
        // Given
        let styles1 = AdyenButtonStyles(
            destructive: AdyenButtonStyle(
                backgroundColor: .red,
                textColor: .white,
                disabledBackgroundColor: .gray,
                disabledTextColor: .lightGray
            )
        )

        // When
        let styles2 = AdyenButtonStyles(
            primary: styles1.primary,
            secondary: styles1.secondary,
            tertiary: styles1.tertiary,
            destructive: AdyenButtonStyle(
                backgroundColor: .blue,
                textColor: .white,
                disabledBackgroundColor: .gray,
                disabledTextColor: .lightGray
            )
        )

        // Then
        XCTAssertEqual(styles1.destructive.backgroundColor, .red)
        XCTAssertEqual(styles2.destructive.backgroundColor, .blue)
    }

}
