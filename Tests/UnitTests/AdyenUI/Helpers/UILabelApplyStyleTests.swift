//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class UILabelApplyStyleTests: XCTestCase {
    
    func test_apply_shouldSetAllPropertiesFromStyle() {
        // Given
        let label = UILabel()
        let expectedFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        let expectedColor = UIColor.red
        let expectedAlignment = NSTextAlignment.center
        
        let style = AdyenLabelStyle(
            font: expectedFont,
            color: expectedColor,
            textAlignment: expectedAlignment
        )
        
        // When
        label.apply(style)
        
        // Then
        XCTAssertEqual(label.font, expectedFont, "Label font should match style font")
        XCTAssertEqual(label.textColor, expectedColor, "Label text color should match style color")
        XCTAssertEqual(label.textAlignment, expectedAlignment, "Label text alignment should match style text alignment")
    }
    
    func test_apply_shouldOverwritePreviousStyleWhenAppliedMultipleTimes() {
        // Given
        let label = UILabel()
        let firstStyle = AdyenLabelStyle(
            font: UIFont.systemFont(ofSize: 12),
            color: UIColor.blue,
            textAlignment: .left
        )
        let secondStyle = AdyenLabelStyle(
            font: UIFont.systemFont(ofSize: 20, weight: .bold),
            color: UIColor.green,
            textAlignment: .right
        )
        
        // When
        label.apply(firstStyle)
        label.apply(secondStyle)
        
        // Then
        XCTAssertEqual(label.font, secondStyle.font, "Label font should match second style font")
        XCTAssertEqual(label.textColor, secondStyle.color, "Label text color should match second style color")
        XCTAssertEqual(label.textAlignment, secondStyle.textAlignment, "Label text alignment should match second style text alignment")
    }
}
