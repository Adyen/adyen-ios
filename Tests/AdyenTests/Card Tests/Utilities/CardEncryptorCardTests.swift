//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
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

    func testEncryptCardWIthOneFIeldShouldSucceed() {
        var card = Card()
        card.number = "1233467890"
        let key = Dummy.dummyPublicKey
        XCTAssertNotNil(try CardEncryptor.encrypt(card: card, with: key))
    }

    func testEncryptCardShouldThrowOnInvalidKey() {
        XCTAssertThrowsError(try CardEncryptor.encrypt(card: correctCard, with: "test_key")) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.encryptionFailed, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.encryptionFailed.errorDescription)
        }
    }

    func testEncryptCardShouldEncrypt() {
        let key = Dummy.dummyPublicKey
        XCTAssertNotNil(try CardEncryptor.encrypt(card: correctCard, with: key))
    }

    // MARK: - Test encrypting Card number

    func testEncryptNumberShouldEncrypt() {
        let key = Dummy.dummyPublicKey
        XCTAssertNotNil(try CardEncryptor.encrypt(number: "12345678", with: key))
    }
    
    func testEncryptNumberShouldFailWithInvalidPublicKey() {
        XCTAssertThrowsError(try CardEncryptor.encrypt(number: "12345678", with: "test_key")) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.encryptionFailed, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
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
        let key = Dummy.dummyPublicKey
        XCTAssertNotNil(try CardEncryptor.encrypt(securityCode: "123", with: key))
    }

    func testEncryptSecureCodeShouldShouldFailWithInvalidPublicKey() {
        XCTAssertThrowsError(try CardEncryptor.encrypt(securityCode: "123", with: "test_key")) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.encryptionFailed, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
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
        let key = Dummy.dummyPublicKey
        XCTAssertNotNil(try CardEncryptor.encrypt(expirationMonth: "123", with: key))
    }

    func testEncryptExpirationMonthShouldShouldFailWithInvalidPublicKey() {
        XCTAssertThrowsError(try CardEncryptor.encrypt(expirationMonth: "123", with: "test_key")) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.encryptionFailed, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
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
        let key = Dummy.dummyPublicKey
        XCTAssertNotNil(try CardEncryptor.encrypt(expirationYear: "123", with: key))
    }

    func testEncryptExpirationYearShouldShouldFailWithInvalidPublicKey() {
        XCTAssertThrowsError(try CardEncryptor.encrypt(expirationYear: "123", with: "test_key")) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.encryptionFailed, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
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
        let key = Dummy.dummyPublicKey
        XCTAssertNotNil(try CardEncryptor.encryptToken(from: correctCard, with: key))
    }

    func testEncryptTokenShouldShouldFailWithInvalidPublicKey() {
        XCTAssertThrowsError(try CardEncryptor.encryptToken(from: correctCard, with: "test_key")) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.encryptionFailed, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
        }
    }

    func testEncryptToToken() {
        XCTAssertThrowsError(try CardEncryptor.encryptToken(from: Card(), with: "test_key")) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.invalidCard, "Thrown Error is not CardEncryptor.Error.invalidCard")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.invalidCard.localizedDescription)
        }
    }

    func testEncryptToTokenWIthOneFIeldShouldSucceed() {
        var card = Card()
        card.number = "1233467890"
        let key = Dummy.dummyPublicKey
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
        XCTAssertThrowsError(try CardEncryptor.encrypt(bin: "asdwed", with: "key")) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.invalidBin, "Thrown Error is not CardEncryptor.Error.invalidBi")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.invalidBin.errorDescription)
        }
    }

    func testEncryptBINShouldFailWithInvalidPublicKey() {
        let key = "test_invalid_key"
        XCTAssertThrowsError(try CardEncryptor.encrypt(bin: "55000000", with: key)) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.encryptionFailed, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.encryptionFailed.errorDescription)
        }
    }

    func testEncryptBIN() {
        let ecrypted = try! CardEncryptor.encrypt(bin: "55000000", with: Dummy.dummyPublicKey)
        XCTAssertNotNil(ecrypted)
        XCTAssertTrue(ecrypted.hasPrefix("adyenio_0_1_25$"))
    }

    func testAESCCM() {
        let data = NSData(base64Encoded: "eyJleHBpcnlZZWFyIjoiMTk3MiIsImN2YyI6IjY2NiIsImV4cGlyeU1vbnRoIjoiNyIsImhvbGRlck5hbWUiOiJLdW4gamUgZGl0IGxlemVuPyIsIm51bWJlciI6IjA2NTU1OTAzMDAiLCJnZW5lcmF0aW9udGltZSI6IjIwMTMtMDgtMjFUMTI6MDE6MzQuMjQ5WiJ9")!
        let key = NSData(base64Encoded: "Xjmy/REE0Unnzc4+kATHkQtN2+t1xUd/enXOB9IH8Sg=")!
        let iv = NSData(base64Encoded: "2Mk9bTtPn1jdnMr/")!
        let result = Cryptor.AES.CCM.encrypt(data: data, withKey: key, initVector: iv)
        XCTAssertNotNil(result.cipher)
        XCTAssertNil(result.atag)

        var payload = Data()
        payload.append(contentsOf: iv as Data)
        payload.append(result.cipher!)

        let expected = Data(base64Encoded: "2Mk9bTtPn1jdnMr/u/K1o0+81LFIFCGKZCYvS0briKpA53nDEoj/Igqr6XitnBe7FpamUkttm0VY+ZGAhMRCahd6uF/OT9CLw96GAlC48JLX8Jp5ul1OQwzcvsV4Oqn/P9jmiXaFvfpIZ9nfMQRmOWTokDcC6Ga7ihuRC9zunwvcNZsDqVf7chpZz++PBYazRgGbfvIZ9p++Zd1QgWhT3OPT4rNlUKP9VqQ=")!
        XCTAssertEqual(payload, expected)
    }

    @available(iOS 13.0, *)
    func testAESGCM() {
        let data = NSData(base64Encoded: "eyJleHBpcnlZZWFyIjoiMTk3MiIsImN2YyI6IjY2NiIsImV4cGlyeU1vbnRoIjoiNyIsImhvbGRlck5hbWUiOiJLdW4gamUgZGl0IGxlemVuPyIsIm51bWJlciI6IjA2NTU1OTAzMDAiLCJnZW5lcmF0aW9udGltZSI6IjIwMTMtMDgtMjFUMTI6MDE6MzQuMjQ5WiJ9")!
        let key = NSData(base64Encoded: "Xjmy/REE0Unnzc4+kATHkQtN2+t1xUd/enXOB9IH8Sg=")!
        let iv = NSData(base64Encoded: "2Mk9bTtPn1jdnMr/")!
        let result = Cryptor.AES.GCM.encrypt(data: data, withKey: key, initVector: iv)

        var payload = Data()
        let expected: Data
        if #available(iOS 13.0, *) {
            payload.append(contentsOf: iv as Data)
            payload.append(result.cipher!)
            payload.append(result.atag!)
            expected = Data(base64Encoded: "2Mk9bTtPn1jdnMr/Z0tDqFGd16KdRNFKIyqR4bgQFjPzyAbxlRT0vn0Mh9CPrhmp4NYYEBYPZz9ZyLd/pihSWqz99Bs8/am6+OeQeeUQlQvX9OeabajgLa6id2HiAjLOR1ANpxLvXtqlZsQaIeIii7EgTZwz789hiQFKwFz8ia8/E6RJEVGZrw+ZQPrd8w1+9454Agm32L1mcOVC52uQOIJqqJ/43FDTLDE+dUa+4d9ahg==")!
            XCTAssertNotNil(result.cipher)
            XCTAssertNotNil(result.atag)
            XCTAssertEqual(result.atag, Data(base64Encoded: "qJ/43FDTLDE+dUa+4d9ahg=="))
            XCTAssertEqual(result.cipher, Data(base64Encoded: "Z0tDqFGd16KdRNFKIyqR4bgQFjPzyAbxlRT0vn0Mh9CPrhmp4NYYEBYPZz9ZyLd/pihSWqz99Bs8/am6+OeQeeUQlQvX9OeabajgLa6id2HiAjLOR1ANpxLvXtqlZsQaIeIii7EgTZwz789hiQFKwFz8ia8/E6RJEVGZrw+ZQPrd8w1+9454Agm32L1mcOVC52uQOIJq"))
        } else {
            payload.append(contentsOf: iv as Data)
            payload.append(result.cipher!)
            expected = Data(base64Encoded: "2Mk9bTtPn1jdnMr/u/K1o0+81LFIFCGKZCYvS0briKpA53nDEoj/Igqr6XitnBe7FpamUkttm0VY+ZGAhMRCahd6uF/OT9CLw96GAlC48JLX8Jp5ul1OQwzcvsV4Oqn/P9jmiXaFvfpIZ9nfMQRmOWTokDcC6Ga7ihuRC9zunwvcNZsDqVf7chpZz++PBYazRgGbfvIZ9p++Zd1QgWhT3OPT4rNlUKP9VqQ=")!
        }

        XCTAssertEqual(payload.base64EncodedString(), expected.base64EncodedString())
    }
}
