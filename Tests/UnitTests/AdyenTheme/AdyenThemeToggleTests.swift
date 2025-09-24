//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class AdyenThemeToggleTests: XCTestCase {
    
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
}
