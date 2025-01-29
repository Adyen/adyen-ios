//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class UILabelHelpersTests: XCTestCase {
    
    func testStyleInitializer() {
        var style = TextStyle(font: UIFont.boldSystemFont(ofSize: 25.0), color: .blue, textAlignment: .right)
        style.backgroundColor = UIColor.yellow
        let cornerRadius: CGFloat = 20
        style.cornerRounding = .fixed(cornerRadius)
        
        let sut = UILabel(style: style)
        
        XCTAssertEqual(sut.font, style.font)
        XCTAssertEqual(sut.textColor, style.color)
        XCTAssertEqual(sut.textAlignment, style.textAlignment)
        XCTAssertEqual(sut.backgroundColor, style.backgroundColor)
        XCTAssertEqual(sut.layer.cornerRadius, cornerRadius)
        XCTAssertTrue(sut.adjustsFontForContentSizeCategory)
        XCTAssertFalse(sut.translatesAutoresizingMaskIntoConstraints)
    }
    
}
