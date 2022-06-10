//
//  PhoneNumberValidatorTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 9/29/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class PhoneNumberValidatorTests: XCTestCase {

    func testValidNumbers() throws {
        let sut = PhoneNumberValidator()

        XCTAssertTrue(sut.isValid("+12 23"))
        XCTAssertTrue(sut.isValid("1 2"))
        XCTAssertTrue(sut.isValid("12"))
        XCTAssertTrue(sut.isValid("+31 633710939"))
        XCTAssertTrue(sut.isValid("+31633710939"))
        XCTAssertTrue(sut.isValid("+31 633 710 939"))
        XCTAssertTrue(sut.isValid("+31 63 3 710 93 9"))
        XCTAssertTrue(sut.isValid("0031 633710939"))
        XCTAssertTrue(sut.isValid("0031633710939"))
        XCTAssertTrue(sut.isValid("31633710939"))
        XCTAssertTrue(sut.isValid("31 633710939"))
        XCTAssertTrue(sut.isValid("31633710939633710939"))
    }

    func testinvalidNumbers() throws {
        let sut = PhoneNumberValidator()

        XCTAssertFalse(sut.isValid("1"))
        XCTAssertFalse(sut.isValid("316337109396337109393412412421412421412"))
        XCTAssertFalse(sut.isValid("+31+23 123"))
        XCTAssertFalse(sut.isValid("+31 23+ 123"))
        XCTAssertFalse(sut.isValid("+31+23+123"))
    }

}
