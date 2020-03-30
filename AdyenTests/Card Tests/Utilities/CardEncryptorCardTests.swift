//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class CardEncryptorCardTests: XCTestCase {
    
    // MARK: - Test encrypting Card number
    
    func testEncryptNumberShouldReturnNilWithNilNumber() {
        let card = CardEncryptor.Card()
        XCTAssertNoThrow(try card.encryptedNumber(publicKey: "test_key", date: Date()))
        XCTAssertNil(try? card.encryptedNumber(publicKey: "test_key", date: Date()))
    }
    
    func testEncryptNumberShouldFailWithInvalidPublicKey() {
        let card = CardEncryptor.Card(number: "test_number")
        let key = "test_invalid_key"
        XCTAssertThrowsError(try card.encryptedNumber(publicKey: key, date: Date())) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.encryptionFailed, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.encryptionFailed.errorDescription)
        }
    }
    
    // MARK: - Test encrypting Security Code
    
    func testEncryptSecurityCodeShouldReturnNilWithNilSecurityCode() {
        let card = CardEncryptor.Card()
        XCTAssertNoThrow(try card.encryptedSecurityCode(publicKey: "test_key", date: Date()))
        XCTAssertNil(try? card.encryptedSecurityCode(publicKey: "test_key", date: Date()))
    }
    
    func testEncryptSecurityCodeShouldFailWithInvalidPublicKey() {
        let card = CardEncryptor.Card(securityCode: "test_security_code")
        let key = "test_invalid_key"
        XCTAssertThrowsError(try card.encryptedSecurityCode(publicKey: key, date: Date())) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.encryptionFailed, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.encryptionFailed.errorDescription)
        }
    }
    
    // MARK: - Test encrypting Expiry Month
    
    func testEncryptExpiryMonthShouldReturnNilWithNilExpiryMonth() {
        let card = CardEncryptor.Card()
        XCTAssertNoThrow(try card.encryptedExpiryMonth(publicKey: "test_key", date: Date()))
        XCTAssertNil(try? card.encryptedExpiryMonth(publicKey: "test_key", date: Date()))
    }
    
    func testEncryptExpiryMonthShouldFailWithInvalidPublicKey() {
        let card = CardEncryptor.Card(expiryMonth: "test_expiry_month")
        let key = "test_invalid_key"
        XCTAssertThrowsError(try card.encryptedExpiryMonth(publicKey: key, date: Date())) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.encryptionFailed, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.encryptionFailed.errorDescription)
        }
    }
    
    // MARK: - Test encrypting Expiry Year
    
    func testEncryptExpiryYearShouldReturnNilWithNilExpiryYear() {
        let card = CardEncryptor.Card()
        XCTAssertNoThrow(try card.encryptedExpiryYear(publicKey: "test_key", date: Date()))
        XCTAssertNil(try? card.encryptedExpiryYear(publicKey: "test_key", date: Date()))
    }
    
    func testEncryptExpiryYearShouldFailWithInvalidPublicKey() {
        let card = CardEncryptor.Card(expiryYear: "test_expiry_year")
        let key = "test_invalid_key"
        XCTAssertThrowsError(try card.encryptedExpiryYear(publicKey: key, date: Date())) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.encryptionFailed, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.encryptionFailed.errorDescription)
        }
    }
    
    // MARK: - Test encrypting encryptedToToken function
    
    func testEncryptedToTokenShouldFailWithAllNilIvars() {
        let card = CardEncryptor.Card()
        XCTAssertTrue(card.isEmpty)
        XCTAssertThrowsError(try card.encryptedToToken(publicKey: "test_key", holderName: nil)) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.invalidEncryptionArguments, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.invalidEncryptionArguments.errorDescription)
        }
    }
    
    func testEncryptedToTokenShouldFailWithInvalidPublicKey() {
        let card = CardEncryptor.Card(expiryYear: "test_expiry_year")
        let key = "test_invalid_key"
        XCTAssertThrowsError(try card.encryptedToToken(publicKey: key, holderName: nil)) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.encryptionFailed, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.encryptionFailed.errorDescription)
        }
    }
    
}
