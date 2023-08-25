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
        
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: 218521.213969269, currencyCode: "ISK"), 21852121)
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: -218521.213969269, currencyCode: "ISK"), -21852121)
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
        
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: Decimal(218521.213969269), currencyCode: "ISK"), 21852121)
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: Decimal(-218521.213969269), currencyCode: "ISK"), -21852121)
    }
    
    func testDifferentLocales() {
        let amount = 123456
        XCTAssertEqual(AmountFormatter.formatted(amount: amount, currencyCode: "USD", localeIdentifier: "ko_KR"), "US$1,234.56")
        if Available.iOS13 {
            XCTAssertEqual(AmountFormatter.formatted(amount: amount, currencyCode: "USD", localeIdentifier: "fr_FR"), "1 234,56 $US")
            
            XCTAssertEqual(AmountFormatter.formatted(amount: amount, currencyCode: "CVE", localeIdentifier: "ko_KR"), "CVE 123,456")
            XCTAssertEqual(AmountFormatter.formatted(amount: amount, currencyCode: "CVE", localeIdentifier: "fr_FR"), "123 456 CVE")
            
            XCTAssertEqual(AmountFormatter.formatted(amount: amount, currencyCode: "ISK", localeIdentifier: "is_IS"), "1.234,56 ISK")
            XCTAssertEqual(AmountFormatter.formatted(amount: amount, currencyCode: "ISK"), "ISK 1,234.56")
        } else {
            // pre iOS 13 formatting seems to add a character that looks exactly like a space but is not a space.
            XCTAssertEqual(AmountFormatter.formatted(amount: amount, currencyCode: "USD", localeIdentifier: "fr_FR"), "1 234,56 $US")
            
            XCTAssertEqual(AmountFormatter.formatted(amount: amount, currencyCode: "CVE", localeIdentifier: "ko_KR"), "CVE123,456.00")
            XCTAssertEqual(AmountFormatter.formatted(amount: amount, currencyCode: "CVE", localeIdentifier: "fr_FR"), "123 456,00 CVE")
        }
        
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: 1234.56, currencyCode: "USD", localeIdentifier: "ko_KR"), 123456)
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: 1234.56, currencyCode: "USD", localeIdentifier: "fr_FR"), 123456)
        
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: Decimal(123456), currencyCode: "USD", localeIdentifier: "ko_KR"), 12345600)
        XCTAssertEqual(AmountFormatter.minorUnitAmount(from: Decimal(123456), currencyCode: "USD", localeIdentifier: "fr_FR"), 12345600)
        
        XCTAssertEqual(AmountFormatter.decimalAmount(amount, currencyCode: "CVE", localeIdentifier: "ko_KR"), 123456)
        XCTAssertEqual(AmountFormatter.decimalAmount(amount, currencyCode: "CVE", localeIdentifier: "fr_FR"), 123456)
    }
    
    func testAmountWithDifferentLocales() {
        var amountEUR = Amount(value: 12345, currencyCode: "EUR", localeIdentifier: "ko_KR")
        XCTAssertEqual(amountEUR.formatted, "€123.45")
        amountEUR.localeIdentifier = "fr_FR"
        XCTAssertEqual(amountEUR.formatted, "123,45 €")
        
        var amountCVE = Amount(value: 12345, currencyCode: "CVE", localeIdentifier: "ko_KR")
        if Available.iOS13 {
            XCTAssertEqual(amountCVE.formatted, "CVE 12,345")
            amountCVE.localeIdentifier = "fr_FR"
            XCTAssertEqual(amountCVE.formatted, "12 345 CVE")
        } else {
            // pre iOS 13 formatting seems to add a character that looks exactly like a space but is not a space.
            XCTAssertEqual(amountCVE.formatted, "CVE12,345.00")
            amountCVE.localeIdentifier = "fr_FR"
            XCTAssertEqual(amountCVE.formatted, "12 345,00 CVE")
        }
    }
    
    func testAmountComponents() {
        guard Available.iOS13 else { return }
        let comparator: (AmountComponents, (currency: String, value: String)) -> Bool = { lhs, rhs in
            lhs.formattedValue == rhs.value &&
                lhs.formattedCurrencySymbol == rhs.currency
        }
        
        let value = 123456
        
        let suts = [
            Amount(value: value, currencyCode: "USD", localeIdentifier: "ko_KR"),
            Amount(value: value, currencyCode: "USD", localeIdentifier: "fr_FR"),
            Amount(value: value, currencyCode: "CVE", localeIdentifier: "ko_KR"),
            Amount(value: value, currencyCode: "CVE", localeIdentifier: "fr_FR"),
            Amount(value: value, currencyCode: "EUR", localeIdentifier: "ko_KR"),
            Amount(value: value, currencyCode: "EUR", localeIdentifier: "fr_FR")
        ].map(\.formattedComponents)
        
        if Available.iOS13 {
            let comps = [
                ("US$", "1,234.56"),
                ("$US", "1 234,56"),
                ("CVE", "123,456"),
                ("CVE", "123 456"),
                ("€", "1,234.56"),
                ("€", "1 234,56")
            ]
            
            XCTAssertTrue(zip(suts, comps).allSatisfy(comparator))
        } else {
            // pre iOS 13 formatting seems to add a character that looks exactly like a space but is not a space.
            let comps = [
                ("US$", "1,234.56"),
                ("$US", "1 234,56"),
                ("CVE", "123,456.00"),
                ("CVE", "123 456,00"),
                ("€", "1,234.56"),
                ("€", "1 234,56")
            ]
            
            XCTAssertTrue(zip(suts, comps).allSatisfy(comparator))
        }
    }
}
