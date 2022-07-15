//
// Copyright © 2020 Adyen. All rights reserved.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class NumericStringValidatorTests: XCTestCase {
    
    func testValidation() {
        let sut = NumericStringValidator(maximumLength: 15)
        
        // Valid numbers
        XCTAssertTrue(sut.isValid("1234567890"))
        XCTAssertTrue(sut.isValid("2025550117"))
        XCTAssertTrue(sut.isValid("01632960047"))
        XCTAssertTrue(sut.isValid("1900654321"))
        XCTAssertTrue(sut.isValid("0209191010"))
        XCTAssertTrue(sut.isValid("619459919"))
        XCTAssertTrue(sut.isValid("1172317474"))
        XCTAssertTrue(sut.isValid("094628665"))
        XCTAssertTrue(sut.isValid("962075595"))
        XCTAssertTrue(sut.isValid("99511101"))
        XCTAssertTrue(sut.isValid("30932314297"))
        XCTAssertTrue(sut.isValid("801800865"))
        XCTAssertTrue(sut.isValid("7799853872"))
        XCTAssertTrue(sut.isValid("405310264"))
        XCTAssertTrue(sut.isValid("335321372"))
        XCTAssertTrue(sut.isValid("754765111"))
        XCTAssertTrue(sut.isValid("127911114"))
        XCTAssertTrue(sut.isValid("558168941"))
        XCTAssertTrue(sut.isValid("83536628"))
        XCTAssertTrue(sut.isValid("766721620"))
        XCTAssertTrue(sut.isValid("718309649"))
        XCTAssertTrue(sut.isValid("398498"))
        XCTAssertTrue(sut.isValid("765786"))
        XCTAssertTrue(sut.isValid("312925688"))
        XCTAssertTrue(sut.isValid("617251881"))
        XCTAssertTrue(sut.isValid("31113367"))
        XCTAssertTrue(sut.isValid("475807"))
        XCTAssertTrue(sut.isValid("15044"))
        
        // Invalid characters
        XCTAssertFalse(sut.isValid("1234567890lknhdhdlsh"))
        XCTAssertFalse(sut.isValid("123456789l648knhdhdlsh0"))
        XCTAssertFalse(sut.isValid("123456789l648%&%wkhd0"))
        XCTAssertFalse(sut.isValid("123456789l6👴480"))
        XCTAssertFalse(sut.isValid("$7323"))
        XCTAssertFalse(sut.isValid("a7323"))
        XCTAssertFalse(sut.isValid("B7323"))
        XCTAssertFalse(sut.isValid("👴7323"))
        XCTAssertFalse(sut.isValid("+73👨‍🦳"))
        XCTAssertFalse(sut.isValid("+7👨‍🦳1"))
        XCTAssertFalse(sut.isValid("+7B1"))
        XCTAssertFalse(sut.isValid("+7$"))
        XCTAssertFalse(sut.isValid("+$"))
        XCTAssertFalse(sut.isValid("+$6"))
        XCTAssertFalse(sut.isValid("٠,١٢٣٤٥٦٧٨٩"))
        XCTAssertFalse(sut.isValid("𝟠"))
        XCTAssertFalse(sut.isValid("๒"))
        XCTAssertFalse(sut.isValid("㊈"))
        XCTAssertFalse(sut.isValid("㊈"))
        XCTAssertFalse(sut.isValid("万"))
        XCTAssertFalse(sut.isValid("๙"))
        XCTAssertFalse(sut.isValid("7.1"))
        XCTAssertFalse(sut.isValid("9,5"))
        
        // Maximum length
        XCTAssertEqual(sut.maximumLength(for: ""), 15)
        XCTAssertEqual(sut.maximumLength(for: "efew"), 15)
        XCTAssertEqual(sut.maximumLength(for: "73231"), 15)
        XCTAssertEqual(sut.maximumLength(for: "+7👨‍🦳1"), 15)
    }
    
}
