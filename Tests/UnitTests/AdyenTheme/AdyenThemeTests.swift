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

}
