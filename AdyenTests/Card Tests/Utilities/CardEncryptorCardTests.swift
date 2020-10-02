//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class CardEncryptorCardTests: XCTestCase {

    override func tearDown() {
        RSACryptor.deleteRSA(appTag: Dummy.dummyPublicKey.sha1())
    }

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
            XCTAssertTrue(error is Cryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! Cryptor.Error, Cryptor.Error.rsaEncryptionError, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
            XCTAssertEqual(error.localizedDescription, Cryptor.Error.rsaEncryptionError.errorDescription)
        }
    }

    func testEncryptNumberShouldEncrypt() {
        let card = CardEncryptor.Card(number: "test_number")
        let key = Dummy.dummyPublicKey
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
            XCTAssertTrue(error is Cryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! Cryptor.Error, Cryptor.Error.rsaEncryptionError, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
            XCTAssertEqual(error.localizedDescription, Cryptor.Error.rsaEncryptionError.errorDescription)
        }
    }

    func testEncryptSecurityCode() {
        let card = CardEncryptor.Card(securityCode: "test_security_code")
        let key = Dummy.dummyPublicKey
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
            XCTAssertTrue(error is Cryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! Cryptor.Error, Cryptor.Error.rsaEncryptionError, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
            XCTAssertEqual(error.localizedDescription, Cryptor.Error.rsaEncryptionError.errorDescription)
        }
    }

    func testEncryptExpiryMonth() {
        let card = CardEncryptor.Card(expiryMonth: "test_expiry_month")
        let key = Dummy.dummyPublicKey
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
            XCTAssertTrue(error is Cryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! Cryptor.Error, Cryptor.Error.rsaEncryptionError, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
            XCTAssertEqual(error.localizedDescription, Cryptor.Error.rsaEncryptionError.errorDescription)
        }
    }

    func testEncryptExpiryYear() {
        let card = CardEncryptor.Card(expiryYear: "test_expiry_year")
        let key = Dummy.dummyPublicKey
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
            XCTAssertTrue(error is Cryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! Cryptor.Error, Cryptor.Error.rsaEncryptionError, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
            XCTAssertEqual(error.localizedDescription, Cryptor.Error.rsaEncryptionError.errorDescription)
        }
    }

    func testEncryptToToken() {
        let card = CardEncryptor.Card(expiryYear: "test_expiry_year")
        let key = Dummy.dummyPublicKey
        XCTAssertNotNil(try card.encryptedToToken(publicKey: key, holderName: nil))
    }

    func testEncryptedToken() {
        let card = CardEncryptor.Card(expiryYear: "test_expiry_year")
        let key = Dummy.dummyPublicKey

        XCTAssertNotNil( try? CardEncryptor.encryptedToken(for: card, holderName: nil, publicKey: key))
    }

    // MARK: - Test encrypting BIN

    func testEncryptExpiryBINShouldReturnNilWithEmptyBIN() {
        XCTAssertThrowsError(try CardEncryptor.encryptedBin(for: "", publicKey: "key")) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.invalidBin, "Thrown Error is not CardEncryptor.Error.invalidBin")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.invalidBin.errorDescription)
        }

        XCTAssertThrowsError(try CardEncryptor.encryptedBin(for: "asdwed", publicKey: "key")) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.invalidBin, "Thrown Error is not CardEncryptor.Error.invalidBi")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.invalidBin.errorDescription)
        }
    }

    func testEncryptBINShouldFailWithInvalidPublicKey() {
        let key = "test_invalid_key"
        XCTAssertThrowsError(try CardEncryptor.encryptedBin(for: "55000000", publicKey: key)) { error in
            XCTAssertTrue(error is Cryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! Cryptor.Error, Cryptor.Error.rsaEncryptionError, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
            XCTAssertEqual(error.localizedDescription, Cryptor.Error.rsaEncryptionError.errorDescription)
        }
    }

    func testEncryptBIN() {
        let ecrypted = try? CardEncryptor.encryptedBin(for: "55000000", publicKey: Dummy.dummyPublicKey)
        XCTAssertNotNil(ecrypted)
        XCTAssertTrue(ecrypted?.hasPrefix("adyenan0_1_1$") ?? false)
    }
}
