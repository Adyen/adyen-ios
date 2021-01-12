//
// Copyright © 2020 Adyen. All rights reserved.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class AmountFormatterTests: XCTestCase {
    
    func testConversionBetweenMajorToMinorAmounts() {
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: 123.351, currencyCode: "EUR"), 12335)
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: -123.351, currencyCode: "EUR"), -12335)
        
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: 0.239, currencyCode: "EUR"), 23)
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: -0.239, currencyCode: "EUR"), -23)
        
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: 111.113, currencyCode: "USD"), 11111)
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: -111.113, currencyCode: "USD"), -11111)
        
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: 333.119, currencyCode: "EUR"), 33311)
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: -333.119, currencyCode: "EUR"), -33311)
        
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: 218521.213969269, currencyCode: "EUR"), 21852121)
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: -218521.213969269, currencyCode: "EUR"), -21852121)
        
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: 218521.213969269, currencyCode: "JOD"), 218521213)
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: -218521.213969269, currencyCode: "JOD"), -218521213)

        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: 218521.213969269, currencyCode: "JPY"), 218521)
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: -218521.213969269, currencyCode: "JPY"), -218521)

        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: 218521.213969269, currencyCode: "CLF"), 2185212139)
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: -218521.213969269, currencyCode: "CLF"), -2185212139)
    }
    
    func testConversionFromDecimalToMinorAmounts() {
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: Decimal(123.351), currencyCode: "EUR"), 12335)
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: Decimal(-123.351), currencyCode: "EUR"), -12335)

        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: Decimal(0.239), currencyCode: "EUR"), 23)
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: Decimal(-0.239), currencyCode: "EUR"), -23)
        
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: Decimal(111.113), currencyCode: "USD"), 11111)
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: Decimal(-111.113), currencyCode: "USD"), -11111)
        
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: Decimal(333.119), currencyCode: "EUR"), 33311)
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: Decimal(-333.119), currencyCode: "EUR"), -33311)
        
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: Decimal(218521.213969269), currencyCode: "EUR"), 21852121)
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: Decimal(-218521.213969269), currencyCode: "EUR"), -21852121)

        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: Decimal(218521.213969269), currencyCode: "JOD"), 218521213)
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: Decimal(-218521.213969269), currencyCode: "JOD"), -218521213)

        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: Decimal(218521.213969269), currencyCode: "JPY"), 218521)
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: Decimal(-218521.213969269), currencyCode: "JPY"), -218521)

        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: Decimal(218521.213969269), currencyCode: "CLF"), 2185212139)
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: Decimal(-218521.213969269), currencyCode: "CLF"), -2185212139)
    }
}
