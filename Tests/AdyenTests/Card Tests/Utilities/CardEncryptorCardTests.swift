//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable @_spi(AdyenInternal) import AdyenCard
@testable import AdyenEncryption
import XCTest

class CardEncryptorCardTests: XCTestCase {

    let correctCard = Card(number: "1234567890", securityCode: "123", expiryMonth: "12", expiryYear: "2025", holder: "J. Smidt")

    // MARK: - Test encrypt card
    
    func testEncryptCardShouldThrowOnInvalidCard() {
        let card = Card()
        XCTAssertThrowsError(try CardEncryptor.encrypt(card: card, with: "test_key")) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.invalidCard, "Thrown Error is not CardEncryptor.Error.invalidCard")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.invalidCard.errorDescription)
        }
    }

    func testEncryptCardWithOneFieldShouldSucceed() {
        var card = Card()
        card.number = "1233467890"
        let key = Dummy.publicKey
        XCTAssertNotNil(try CardEncryptor.encrypt(card: card, with: key))
    }

    func testEncryptCardShouldThrowOnInvalidKey() {
        XCTAssertThrowsError(try CardEncryptor.encrypt(card: correctCard, with: "test_key")) { error in
            XCTAssertTrue(error is EncryptionError, "Thrown Error is not JsonWebEncryptionError")
            XCTAssertEqual(error.localizedDescription, EncryptionError.invalidKey.errorDescription)
        }
    }

    func testEncryptCardShouldEncrypt() {
        let key = Dummy.publicKey
        XCTAssertNotNil(try CardEncryptor.encrypt(card: correctCard, with: key))
    }

    // MARK: - Test encrypting Card number

    func testEncryptNumberShouldEncrypt() {
        let key = Dummy.publicKey
        XCTAssertNotNil(try CardEncryptor.encrypt(number: "12345678", with: key))
    }
    
    func testEncryptNumberShouldFailWithInvalidPublicKey() {
        XCTAssertThrowsError(try CardEncryptor.encrypt(number: "12345678", with: "test_key")) { error in
            XCTAssertTrue(error is EncryptionError, "Thrown Error is not JsonWebEncryptionError")
            XCTAssertEqual(error.localizedDescription, EncryptionError.invalidKey.localizedDescription)
        }
    }

    func testEncryptEmptyNumber() {
        XCTAssertThrowsError(try CardEncryptor.encrypt(number: "", with: "test_key")) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.invalidNumber, "Thrown Error is not CardEncryptor.Error.invalidNumber")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.invalidNumber.localizedDescription)
        }
    }
    
    // MARK: - Test encrypting Security Code
    
    func testEncryptSecureCodeShouldEncrypt() {
        let key = Dummy.publicKey
        XCTAssertNotNil(try CardEncryptor.encrypt(securityCode: "123", with: key))
    }

    func testEncryptSecureCodeShouldShouldFailWithInvalidPublicKey() {
        XCTAssertThrowsError(try CardEncryptor.encrypt(securityCode: "123", with: "test_key")) { error in
            XCTAssertTrue(error is EncryptionError, "Thrown Error is not JsonWebEncryptionError")
            XCTAssertEqual(error.localizedDescription, EncryptionError.invalidKey.localizedDescription)
        }
    }

    func testEncryptEmptySecurityCode() {
        XCTAssertThrowsError(try CardEncryptor.encrypt(securityCode: "", with: "test_key")) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.invalidSecureCode, "Thrown Error is not CardEncryptor.Error.invalidSecureCode")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.invalidSecureCode.localizedDescription)
        }
    }
    
    // MARK: - Test encrypting Expiry Month
    
    func testEncryptExpirationMonthShouldEncrypt() {
        let key = Dummy.publicKey
        XCTAssertNotNil(try CardEncryptor.encrypt(expirationMonth: "123", with: key))
    }

    func testEncryptExpirationMonthShouldShouldFailWithInvalidPublicKey() {
        XCTAssertThrowsError(try CardEncryptor.encrypt(expirationMonth: "123", with: "test_key")) { error in
            XCTAssertTrue(error is EncryptionError, "Thrown Error is not JsonWebEncryptionError")
            XCTAssertEqual(error.localizedDescription, EncryptionError.invalidKey.errorDescription)
        }
    }

    func testEncryptEmptyExpiryMonth() {
        XCTAssertThrowsError(try CardEncryptor.encrypt(expirationMonth: "", with: "test_key")) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.invalidExpiryMonth, "Thrown Error is not CardEncryptor.Error.invalidExpiryMonth")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.invalidExpiryMonth.localizedDescription)
        }
    }
    
    // MARK: - Test encrypting Expiry Year
    
    func testEncryptExpirationYearShouldEncrypt() {
        let key = Dummy.publicKey
        XCTAssertNotNil(try CardEncryptor.encrypt(expirationYear: "123", with: key))
    }

    func testEncryptExpirationYearShouldShouldFailWithInvalidPublicKey() {
        XCTAssertThrowsError(try CardEncryptor.encrypt(expirationYear: "123", with: "test_key")) { error in
            XCTAssertTrue(error is EncryptionError, "Thrown Error is not JsonWebEncryptionError")
            XCTAssertEqual(error.localizedDescription, EncryptionError.invalidKey.localizedDescription)
        }
    }

    func testEncryptEmptyExpiryYear() {
        XCTAssertThrowsError(try CardEncryptor.encrypt(expirationYear: "", with: "test_key")) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.invalidExpiryYear, "Thrown Error is not CardEncryptor.Error.invalidExpiryYear")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.invalidExpiryYear.localizedDescription)
        }
    }
    
    // MARK: - Test encrypting encryptedToToken function
    
    func testEncryptTokenShouldEncrypt() {
        let key = Dummy.publicKey
        XCTAssertNotNil(try CardEncryptor.encryptToken(from: correctCard, with: key))
    }

    func testEncryptTokenShouldShouldFailWithInvalidPublicKey() {
        XCTAssertThrowsError(try CardEncryptor.encryptToken(from: correctCard, with: "test_key")) { error in
            XCTAssertTrue(error is EncryptionError, "Thrown Error is not JsonWebEncryptionError")
            XCTAssertEqual(error.localizedDescription, EncryptionError.invalidKey.localizedDescription)
        }
    }

    func testEncryptToToken() {
        XCTAssertThrowsError(try CardEncryptor.encryptToken(from: Card(), with: "test_key")) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.invalidCard, "Thrown Error is not CardEncryptor.Error.invalidCard")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.invalidCard.localizedDescription)
        }
    }

    func testEncryptToTokenWithOneFieldShouldSucceed() {
        var card = Card()
        card.number = "1233467890"
        let key = Dummy.publicKey
        XCTAssertNotNil(try CardEncryptor.encryptToken(from: card, with: key))
    }

    // MARK: - Test encrypting BIN

    func testEncryptExpiryBINShouldReturnNilWithEmptyBIN() {
        XCTAssertThrowsError(try CardEncryptor.encrypt(bin: "", with: "key")) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.invalidBin, "Thrown Error is not CardEncryptor.Error.invalidBin")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.invalidBin.errorDescription)
        }
    }

    func testEncryptExpiryBINShouldReturnNilWithInvalidBIN() {
        XCTAssertThrowsError(try CardEncryptor.encrypt(bin: "invalid_BIN", with: "key")) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.invalidBin, "Thrown Error is not CardEncryptor.Error.invalidBi")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.invalidBin.errorDescription)
        }
    }

    func testEncryptBINShouldFailWithInvalidPublicKey() {
        let key = "test_invalid_key"
        XCTAssertThrowsError(try CardEncryptor.encrypt(bin: "55000000", with: key)) { error in
            XCTAssertTrue(error is EncryptionError, "Thrown Error is not EncryptionError")
            XCTAssertEqual(error.localizedDescription, EncryptionError.invalidKey.errorDescription)
        }
    }

    func testEncryptBIN() {
        let encrypted = try! CardEncryptor.encrypt(bin: "55000000", with: Dummy.publicKey)
        XCTAssertNotNil(encrypted)
        XCTAssertTrue(encrypted.hasPrefix("eyJlbmMiOiJBMjU2Q0JDLUhTNTEyIiwiYWxnIjoiUlNBLU9BRVAtMjU2IiwidmVyc2lvbiI6IjEifQ"))
    }
}
