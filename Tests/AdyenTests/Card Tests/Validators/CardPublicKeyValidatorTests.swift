//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable @_spi(AdyenInternal) import AdyenCard
import XCTest

class CardPublicKeyValidatorTests: XCTestCase {

    var sut: CardPublicKeyValidator!

    override func setUp() {
        sut = CardPublicKeyValidator()
    }

    override func tearDown() {
        sut = nil
    }
    
    func testInvalideCharacters() {
        XCTAssertFalse(sut.isValid("fwwefv"))
    }
    
    func testMissingPipChar() {
        XCTAssertFalse(sut.isValid("\(RandomStringGenerator.generateRandomNumericString(length: 5))\(RandomStringGenerator.generateRandomHexadecimalString(length: 512))"))
    }
    
    func testWrongStringBeforeThePipChar() {
        XCTAssertFalse(sut.isValid("123GH|\(RandomStringGenerator.generateRandomHexadecimalString(length: 512))"))
    }
    
    func testWrongStringAfterThePipChar() {
        XCTAssertFalse(sut.isValid("12345|\(RandomStringGenerator.generateRandomHexadecimalString(length: 25))"))
    }
    
    func testValidKey() {
        XCTAssertTrue(sut.isValid(RandomStringGenerator.generateDummyCardPublicKey()))
    }
    
    func testLength() {
        XCTAssertEqual(sut.maximumLength(for: "test_value"), 518)
    }
    
}
