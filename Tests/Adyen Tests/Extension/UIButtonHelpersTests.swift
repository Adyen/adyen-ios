//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class UIButtonHelperTests: XCTestCase {
    
    func testStyleInitializer() {
        let cornerRadius: CGFloat = 20
        var style = ButtonStyle(
            title: TextStyle(font: UIFont.boldSystemFont(ofSize: 25.0), color: .blue, textAlignment: .right),
            cornerRounding: .fixed(cornerRadius),
            background: .brown
        )
        style.borderColor = UIColor.yellow
        style.borderWidth = 10
        style.backgroundColor = .darkGray
        
        let sut = UIButton(style: style)
        
        XCTAssertEqual(sut.titleLabel?.font, style.title.font)
        XCTAssertEqual(sut.titleLabel?.textColor, style.title.color)
        XCTAssertEqual(sut.titleColor(for: .normal), style.title.color)
        XCTAssertEqual(sut.titleLabel?.textAlignment, style.title.textAlignment)
        XCTAssertTrue(sut.titleLabel!.adjustsFontForContentSizeCategory)
        XCTAssertEqual(sut.backgroundColor, style.backgroundColor)
        XCTAssertEqual(sut.layer.borderColor, style.borderColor?.cgColor)
        XCTAssertEqual(sut.layer.borderWidth, style.borderWidth)
        XCTAssertEqual(sut.layer.cornerRadius, cornerRadius)
        XCTAssertFalse(sut.translatesAutoresizingMaskIntoConstraints)
    }
    
}
