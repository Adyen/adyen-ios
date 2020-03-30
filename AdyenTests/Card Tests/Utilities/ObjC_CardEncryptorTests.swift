//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class ObjC_CardEncryptorTests: XCTestCase {
    
    func testEncryptorWithNilNumber() {
        XCTAssertNil(ObjC_CardEncryptor.encryptedNumber(nil, publicKey: "test_key", date: Date()))
    }
    
    func testEncryptorWithNilSecurityCode() {
        XCTAssertNil(ObjC_CardEncryptor.encryptedSecurityCode(nil, publicKey: "test_key", date: Date()))
    }
    
    func testEncryptorWithNilExpiryMonth() {
        XCTAssertNil(ObjC_CardEncryptor.encryptedExpiryMonth(nil, publicKey: "test_key", date: Date()))
    }
    
    func testEncryptorWithNilExpiryYear() {
        XCTAssertNil(ObjC_CardEncryptor.encryptedExpiryMonth(nil, publicKey: "test_key", date: Date()))
    }
    
    func testEncryptorWithTokenGeneration() {
        XCTAssertNil(ObjC_CardEncryptor.encryptedToToken(withNumber: nil, securityCode: nil, expiryMonth: nil, expiryYear: nil, holderName: nil, publicKey: "test_key"))
    }
}
