//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
@testable import AdyenEncryption
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
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.encryptionFailed, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.encryptionFailed.errorDescription)
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
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.encryptionFailed, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.encryptionFailed.errorDescription)
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
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.encryptionFailed, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.encryptionFailed.errorDescription)
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
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.encryptionFailed, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.encryptionFailed.errorDescription)
        }
    }

    func testEncryptToToken() {
        let card = CardEncryptor.Card(expiryYear: "test_expiry_year")
        let key = Dummy.dummyPublicKey
        XCTAssertNotNil(try card.encryptedToToken(publicKey: key, holderName: nil))
    }

    // MARK: - Test encrypting BIN

    func testEncryptExpiryBINShouldReturnNilWithEmptyBIN() {
        XCTAssertThrowsError(try CardEncryptor.encryptedBin(for: "", publicKey: "key")) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.invalidBin, "Thrown Error is not CardEncryptor.Error.invalidBin")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.invalidBin.errorDescription)
        }
    }

    func testEncryptExpiryBINShouldReturnNilWithInvalidBIN() {
        XCTAssertThrowsError(try CardEncryptor.encryptedBin(for: "asdwed", publicKey: "key")) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.invalidBin, "Thrown Error is not CardEncryptor.Error.invalidBi")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.invalidBin.errorDescription)
        }
    }

    func testEncryptBINShouldFailWithInvalidPublicKey() {
        let key = "test_invalid_key"
        XCTAssertThrowsError(try CardEncryptor.encryptedBin(for: "55000000", publicKey: key)) { error in
            XCTAssertTrue(error is CardEncryptor.Error, "Thrown Error is not CardEncryptor.Error")
            XCTAssertEqual(error as! CardEncryptor.Error, CardEncryptor.Error.encryptionFailed, "Thrown Error is not CardEncryptor.Error.encryptionFailed")
            XCTAssertEqual(error.localizedDescription, CardEncryptor.Error.encryptionFailed.errorDescription)
        }
    }

    func testEncryptBIN() {
        let ecrypted = try! CardEncryptor.encryptedBin(for: "55000000", publicKey: Dummy.dummyPublicKey)
        XCTAssertNotNil(ecrypted)
        if #available(iOS 13.0, *) {
            XCTAssertTrue(ecrypted.hasPrefix("adyenio0_1_2$"))
        } else {
            XCTAssertTrue(ecrypted.hasPrefix("adyenio0_1_1$"))
        }
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
