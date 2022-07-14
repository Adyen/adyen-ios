//
//  BankDetailsEncryptorTests.swift
//  AdyenUIKitTests
//
//  Created by Eren Besel on 1/19/22.
//  Copyright © 2022 Adyen. All rights reserved.
//

@testable @_spi(AdyenInternal) import AdyenCard
@testable import AdyenEncryption
import XCTest

class BankDetailsEncryptorTests: XCTestCase {

    // Account number
    func testEncryptNumberShouldEncrypt() {
        let key = Dummy.publicKey
        XCTAssertNotNil(try BankDetailsEncryptor.encrypt(accountNumber: "123456789", with: key))
    }
    
    func testEncryptNumberShouldFailWithInvalidPublicKey() {
        XCTAssertThrowsError(try BankDetailsEncryptor.encrypt(accountNumber: "123456789", with: "test_key")) { error in
            XCTAssertTrue(error is EncryptionError, "Thrown Error is not JsonWebEncryptionError")
            XCTAssertEqual(error.localizedDescription, EncryptionError.invalidKey.localizedDescription)
        }
    }

    func testEncryptEmptyNumber() {
        XCTAssertThrowsError(try BankDetailsEncryptor.encrypt(accountNumber: "", with: "test_key")) { error in
            XCTAssertTrue(error is BankDetailsEncryptor.Error, "Thrown Error is not BankDetailsEncryptor.Error")
            XCTAssertEqual(error as! BankDetailsEncryptor.Error, BankDetailsEncryptor.Error.invalidAccountNumber, "Thrown Error is not BankDetailsEncryptor.Error.invalidAccountNumber")
            XCTAssertEqual(error.localizedDescription, BankDetailsEncryptor.Error.invalidAccountNumber.localizedDescription)
        }
    }
    
    // Routing number
    func testEncryptRoutingNumberShouldEncrypt() {
        let key = Dummy.publicKey
        XCTAssertNotNil(try BankDetailsEncryptor.encrypt(routingNumber: "123456789", with: key))
    }
    
    func testEncryptRoutingNumberShouldFailWithInvalidPublicKey() {
        XCTAssertThrowsError(try BankDetailsEncryptor.encrypt(routingNumber: "123456789", with: "test_key")) { error in
            XCTAssertTrue(error is EncryptionError, "Thrown Error is not JsonWebEncryptionError")
            XCTAssertEqual(error.localizedDescription, EncryptionError.invalidKey.localizedDescription)
        }
    }

    func testEncryptEmptyRoutingNumber() {
        XCTAssertThrowsError(try BankDetailsEncryptor.encrypt(routingNumber: "", with: "test_key")) { error in
            XCTAssertTrue(error is BankDetailsEncryptor.Error, "Thrown Error is not BankDetailsEncryptor.Error")
            XCTAssertEqual(error as! BankDetailsEncryptor.Error, BankDetailsEncryptor.Error.invalidRoutingNumber, "Thrown Error is not BankDetailsEncryptor.Error.invalidRoutingNumber")
            XCTAssertEqual(error.localizedDescription, BankDetailsEncryptor.Error.invalidRoutingNumber.localizedDescription)
        }
    }
}
