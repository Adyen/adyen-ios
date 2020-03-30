//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class CardPublicKeyValidatorTests: XCTestCase {
    
    func testInvalideCharacters() {
        let sut = CardPublicKeyValidator()
        XCTAssertFalse(sut.isValid("fwwefv"))
    }
    
    func testMissingPipChar() {
        let sut = CardPublicKeyValidator()
        XCTAssertFalse(sut.isValid("\(RandomStringGenerator.generateRandomNumericString(length: 5))\(RandomStringGenerator.generateRandomAlphaNumericString(length: 512))"))
    }
    
    func testWrongStringBeforeThePipChar() {
        let sut = CardPublicKeyValidator()
        XCTAssertFalse(sut.isValid("123GH|\(RandomStringGenerator.generateRandomAlphaNumericString(length: 512))"))
    }
    
    func testWrongStringAfterThePipChar() {
        let sut = CardPublicKeyValidator()
        XCTAssertFalse(sut.isValid("12345|\(RandomStringGenerator.generateRandomAlphaNumericString(length: 25))"))
    }
    
    func testValidKey() {
        let sut = CardPublicKeyValidator()
        XCTAssertTrue(sut.isValid(RandomStringGenerator.generateDummyCardPublicKey()))
    }
    
    func testLength() {
        let sut = CardPublicKeyValidator()
        XCTAssertEqual(sut.maximumLength(for: "test_value"), 518)
    }
    
}
