//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class CardEncryptorCardTests: XCTestCase {

    // This is not a real public key, this is just a random string with the right pattern.
    private static var randomTestValidCardPublicKey = "59554|59YWNVYSILHQWVXSIYY8XVK5HMLEAFT2JPJBDVHUD2798K12GKE652PYLJYYNBR0HVN0AYLC38VIU0TSBC9JTQZ4AHOHPPIGVH985H6EI5HAFZXZAM0QIXBAYEP180X0MM6HRHZONIM62TI9US8NXHXNKYSRE8ASJLY3KED6KDD6SY4I29CUY5FYTN8XEQ8NS8M0ECUAG0GV08XAX19HEX8IQ35SNRY8P9G0YOTTEFYC8QGM7N4PYRUWTSOEJV8W9AKJ8ZLR851OA0P7NZOJXZ2EOYNWSORS9RL4HGXVXGANDYXOWCD7XYPHJD6EPYGRUDV87EOT5FHR574DJW5881Y88Y2QR6R9W1WG5N0CV3WJGELJ971OR0S0PTKHOFW7PXRRDVQU1TT4Q8KJJLZ2VHS1BYP0VFQY1FOADWZ2YPGXDT6KPSN6OJ81G9B9BO7LMGYIONUDWQZQM41O27RROX44I89WRLHZHNYP5NEF2ACTF1AJHA4SNTUN9Z93HYQ2"
    
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

    func testEncryptNumberShouldEncrypt() {
        CardEncryptor.cleanPublicKeys(publicKeyToken: CardEncryptorCardTests.randomTestValidCardPublicKey)
        let card = CardEncryptor.Card(number: "test_number")
        let key = CardEncryptorCardTests.randomTestValidCardPublicKey
        XCTAssertNotNil(try card.encryptedNumber(publicKey: key, date: Date()))
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

    func testEncryptSecurityCode() {
        CardEncryptor.cleanPublicKeys(publicKeyToken: CardEncryptorCardTests.randomTestValidCardPublicKey)
        let card = CardEncryptor.Card(securityCode: "test_security_code")
        let key = CardEncryptorCardTests.randomTestValidCardPublicKey
        XCTAssertNotNil(try card.encryptedSecurityCode(publicKey: key, date: Date()))
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

    func testEncryptExpiryMonth() {
        CardEncryptor.cleanPublicKeys(publicKeyToken: CardEncryptorCardTests.randomTestValidCardPublicKey)
        let card = CardEncryptor.Card(expiryMonth: "test_expiry_month")
        let key = CardEncryptorCardTests.randomTestValidCardPublicKey
        XCTAssertNotNil(try card.encryptedExpiryMonth(publicKey: key, date: Date()))
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

    func testEncryptExpiryYear() {
        CardEncryptor.cleanPublicKeys(publicKeyToken: CardEncryptorCardTests.randomTestValidCardPublicKey)
        let card = CardEncryptor.Card(expiryYear: "test_expiry_year")
        let key = CardEncryptorCardTests.randomTestValidCardPublicKey
        XCTAssertNotNil(try card.encryptedExpiryYear(publicKey: key, date: Date()))
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

    func testEncryptToToken() {
        CardEncryptor.cleanPublicKeys(publicKeyToken: CardEncryptorCardTests.randomTestValidCardPublicKey)
        let card = CardEncryptor.Card(expiryYear: "test_expiry_year")
        let key = CardEncryptorCardTests.randomTestValidCardPublicKey
        XCTAssertNotNil(try card.encryptedToToken(publicKey: key, holderName: nil))
    }
    
}
