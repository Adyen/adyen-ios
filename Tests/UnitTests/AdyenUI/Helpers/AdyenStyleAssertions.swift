//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

extension XCTestCase {
    
    package func expect(
        _ actualStyle: AdyenTextFieldStyle,
        toMatch expectedStyle: AdyenTextFieldStyle,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(actualStyle.backgroundColor, expectedStyle.backgroundColor, "textfield backgroundColor mismatch", file: file, line: line)
        XCTAssertEqual(actualStyle.errorColor, expectedStyle.errorColor, "textfield errorColor mismatch", file: file, line: line)
        XCTAssertEqual(actualStyle.cornerRadius, expectedStyle.cornerRadius, "textfield cornerRadius mismatch", file: file, line: line)
        XCTAssertEqual(actualStyle.borderColor, expectedStyle.borderColor, "textfield borderColor mismatch", file: file, line: line)
        XCTAssertEqual(actualStyle.borderWidth, expectedStyle.borderWidth, "textfield borderWidth mismatch", file: file, line: line)
    }
    
    package func expect(
        _ actualStyle: AdyenLabelStyle,
        matches expectedStyle: AdyenLabelStyle,
        property: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(actualStyle.color, expectedStyle.color, "\(property) color mismatch", file: file, line: line)
        XCTAssertEqual(actualStyle.font, expectedStyle.font, "\(property) font mismatch", file: file, line: line)
        XCTAssertEqual(actualStyle.disabledColor, expectedStyle.disabledColor, "\(property) disabledColor mismatch", file: file, line: line)
        XCTAssertEqual(actualStyle.textAlignment, expectedStyle.textAlignment, "\(property) textAlignment mismatch", file: file, line: line)
    }
    
    package func expect(
        _ actualStyle: AdyenLabelStyle,
        toMatch expectedStyle: AdyenLabelStyle,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(actualStyle.color, expectedStyle.color, " label color mismatch", file: file, line: line)
        XCTAssertEqual(actualStyle.font, expectedStyle.font, "label font mismatch", file: file, line: line)
        XCTAssertEqual(actualStyle.disabledColor, expectedStyle.disabledColor, "label disabledColor mismatch", file: file, line: line)
        XCTAssertEqual(actualStyle.textAlignment, expectedStyle.textAlignment, "label textAlignment mismatch", file: file, line: line)
    }
    
    package func expect(
        _ actualStyle: AdyenButtonStyles,
        toMatch expectedStyle: AdyenButtonStyles,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(actualStyle.primary, expectedStyle.primary, "primary button mismatch", file: file, line: line)
        XCTAssertEqual(actualStyle.secondary, expectedStyle.secondary, "secondary button mismatch", file: file, line: line)
        XCTAssertEqual(actualStyle.tertiary, expectedStyle.tertiary, "tertiary button mismatch", file: file, line: line)
        XCTAssertEqual(actualStyle.destructive, expectedStyle.destructive, "destructive button mismatch", file: file, line: line)
    }
    
    package func expect(
        _ actualStyle: AdyenSwitchStyle,
        toMatch expectedStyle: AdyenSwitchStyle,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(actualStyle.tintColor, expectedStyle.tintColor, "toggle tintColor mismatch", file: file, line: line)
        XCTAssertEqual(actualStyle.backgroundColor, expectedStyle.backgroundColor, "toggle backgroundColor mismatch", file: file, line: line)
        XCTAssertEqual(actualStyle.cornerRadius, expectedStyle.cornerRadius, "toggle cornerRadius mismatch", file: file, line: line)
    }
}
