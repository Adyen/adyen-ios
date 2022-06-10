//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable @_spi(AdyenInternal) import AdyenCard
import XCTest

class CardExpiryDateValidatorTests: XCTestCase {
    
    func testValidExpiryDates() {
        let validator = CardExpiryDateValidator(referenceDate: getReferenceDate())
        
        XCTAssertTrue(validator.isValid("1020"))
        XCTAssertTrue(validator.isValid("0820"))
        XCTAssertTrue(validator.isValid("0121"))
        
        // Test date less than 30 years in the future from reference date 01/01/2020.
        XCTAssertTrue(validator.isValid("0130"))
        XCTAssertTrue(validator.isValid("0140"))
        XCTAssertTrue(validator.isValid("0150"))
        
        // Test date 30 years in the future from reference date 01/01/2020.
        XCTAssertTrue(validator.isValid("0150"))
        
        // Test date 3 months in the past from reference date 01/01/2020.
        XCTAssertTrue(validator.isValid("1019"))
    }
    
    private func getReferenceDate() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.day = 1
        components.month = 1
        components.year = 2020
        return calendar.date(from: components)!
    }
    
    func testInvalidExpiryDates() {
        let validator = CardExpiryDateValidator(referenceDate: getReferenceDate())
        
        // Invalid length.
        XCTAssertFalse(validator.isValid(""))
        XCTAssertFalse(validator.isValid("1"))
        XCTAssertFalse(validator.isValid("12"))
        XCTAssertFalse(validator.isValid("12345"))
        
        // Invalid characters.
        XCTAssertFalse(validator.isValid("12Ab"))
        XCTAssertFalse(validator.isValid("A23b"))
        XCTAssertFalse(validator.isValid("😂23b"))
        
        // More than 3 months in the past from reference date 01/01/2020.
        XCTAssertFalse(validator.isValid("0917"))
        XCTAssertFalse(validator.isValid("0101"))
        XCTAssertFalse(validator.isValid("0819"))
        XCTAssertFalse(validator.isValid("0919"))
        
        // More than 30 years in the future from reference date 01/01/2020.
        XCTAssertFalse(validator.isValid("0151"))
        
        // Invalid month.
        XCTAssertFalse(validator.isValid("1320"))
        XCTAssertFalse(validator.isValid("0020"))
        
    }
    
}
