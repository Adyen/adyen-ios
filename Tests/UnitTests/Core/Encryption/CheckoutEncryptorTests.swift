//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenEncryption
import Foundation
import Testing

struct CheckoutEncryptorTests {

    private static let fieldKeys: [(field: CheckoutEncryptor.Field, key: String)] = [
        (.cardNumber, "number"),
        (.securityCode, "cvc"),
        (.expiryMonth, "expiryMonth"),
        (.expiryYear, "expiryYear"),
        (.kcpPassword, "password"),
        (.bankAccountNumber, "bankAccountNumber"),
        (.bankRoutingNumber, "bankLocationId"),
        (.bin, "binValue")
    ]

    private static let jweHeaderPrefix = "eyJhbGciOiJSU0EtT0FFUC0yNTYiLCJlbmMiOiJBMjU2Q0JDLUhTNTEyIiwidmVyc2lvbiI6IjEifQ"

    private static var exponent: String {
        String(Dummy.publicKey.prefix(5))
    }

    private static var modulus: String {
        String(Dummy.publicKey.suffix(512))
    }

    static let malformedPublicKeys: [String] = [
        "",
        "test_key",
        exponent + modulus,
        exponent + "|" + modulus + "|" + exponent,
        Dummy.publicKey.lowercased(),
        String(exponent.dropLast()) + "|" + modulus,
        exponent + "0|" + modulus,
        exponent + "|" + String(modulus.dropLast()),
        exponent + "|" + modulus + "0",
        exponent + "|G" + String(modulus.dropFirst()),
        " " + Dummy.publicKey,
        Dummy.publicKey + " ",
        Dummy.publicKey + "\n"
    ]

    // MARK: - Payload

    @Test func fieldPayload_shouldEncodeFieldKeyValueAndGenerationTime() throws {
        for (field, key) in Self.fieldKeys {
            let payload = FieldPayload(field: field, value: "1234", timestamp: Date(timeIntervalSince1970: 0))

            let json = try JSONSerialization.jsonObject(with: payload.jsonData()) as? [String: String]

            #expect(json == [key: "1234", "generationtime": "1970-01-01T00:00:00Z"], "\(key)")
        }
    }

    // MARK: - Encrypt field

    @Test func encryptField_withValidPublicKey_shouldReturnCompactJWE() throws {
        for (field, key) in Self.fieldKeys {
            let encrypted = try CheckoutEncryptor.encrypt(field: field, value: "1234", publicKey: Dummy.publicKey)

            #expect(encrypted.components(separatedBy: ".").count == 5, "\(key)")
            #expect(encrypted.hasPrefix(Self.jweHeaderPrefix), "\(key)")
        }
    }

    @Test(arguments: ["", "abc", " 12 ", "12/34"])
    func encryptField_withUnvalidatedValue_shouldEncrypt(value: String) throws {
        let encrypted = try CheckoutEncryptor.encrypt(field: .cardNumber, value: value, publicKey: Dummy.publicKey)

        #expect(encrypted.components(separatedBy: ".").count == 5)
    }

    @Test(arguments: malformedPublicKeys)
    func encryptField_withMalformedPublicKey_shouldThrowInvalidPublicKey(publicKey: String) {
        let error = #expect(throws: CheckoutEncryptor.Error.self) {
            try CheckoutEncryptor.encrypt(field: .cardNumber, value: "1234", publicKey: publicKey)
        }

        #expect(error?.code == .invalidPublicKey)
        #expect(error?.underlyingError == nil)
    }

    @Test func encryptField_withUnparsablePublicKey_shouldThrowInvalidPublicKeyWithUnderlyingError() {
        let publicKey = String(repeating: "0", count: 5) + "|" + String(repeating: "0", count: 512)

        let error = #expect(throws: CheckoutEncryptor.Error.self) {
            try CheckoutEncryptor.encrypt(field: .cardNumber, value: "1234", publicKey: publicKey)
        }

        #expect(error?.code == .invalidPublicKey)
        #expect(error?.underlyingError != nil)
    }

    @Test func encrypt_whenGenerationFails_shouldThrowEncryptionFailedWithUnderlyingError() throws {
        let generator = JSONWebEncryptionGeneratorMock()
        generator.onGenerate = { _, _, _ in throw Dummy.error }
        let key = try CheckoutEncryptor.makeSecKey(from: Dummy.publicKey)

        let error = #expect(throws: CheckoutEncryptor.Error.self) {
            try CheckoutEncryptor.encrypt(FieldPayload(field: .cardNumber, value: "1234"), with: key, generator: generator)
        }

        #expect(error?.code == .encryptionFailed)
        #expect(error?.underlyingError as? Dummy == .error)
        #expect(generator.generateCallsCount == 1)
    }

    // MARK: - Encrypt card

    @Test func encryptCard_withAllFields_shouldEncryptAllFields() throws {
        let card = CheckoutCard(number: "4111111111111111", securityCode: "737", expiryMonth: "03", expiryYear: "2030")

        let encrypted = try CheckoutEncryptor.encrypt(card: card, publicKey: Dummy.publicKey)

        #expect(encrypted.number?.hasPrefix(Self.jweHeaderPrefix) == true)
        #expect(encrypted.securityCode?.hasPrefix(Self.jweHeaderPrefix) == true)
        #expect(encrypted.expiryMonth?.hasPrefix(Self.jweHeaderPrefix) == true)
        #expect(encrypted.expiryYear?.hasPrefix(Self.jweHeaderPrefix) == true)
    }

    @Test func encryptCard_withOnlyExpiryMonth_shouldEncryptOnlyExpiryMonth() throws {
        let encrypted = try CheckoutEncryptor.encrypt(card: CheckoutCard(expiryMonth: "03"), publicKey: Dummy.publicKey)

        #expect(encrypted.number == nil)
        #expect(encrypted.securityCode == nil)
        #expect(encrypted.expiryMonth != nil)
        #expect(encrypted.expiryYear == nil)
    }

    @Test func encryptCard_withOnlyExpiryYear_shouldEncryptOnlyExpiryYear() throws {
        let encrypted = try CheckoutEncryptor.encrypt(card: CheckoutCard(expiryYear: "2030"), publicKey: Dummy.publicKey)

        #expect(encrypted.number == nil)
        #expect(encrypted.securityCode == nil)
        #expect(encrypted.expiryMonth == nil)
        #expect(encrypted.expiryYear != nil)
    }

    @Test(arguments: [Dummy.publicKey, "test_key"])
    func encryptCard_withNoFields_shouldThrowInvalidCard(publicKey: String) {
        let error = #expect(throws: CheckoutEncryptor.Error.self) {
            try CheckoutEncryptor.encrypt(card: CheckoutCard(), publicKey: publicKey)
        }

        #expect(error?.code == .invalidCard)
        #expect(error?.underlyingError == nil)
    }

    @Test(arguments: malformedPublicKeys)
    func encryptCard_withMalformedPublicKey_shouldThrowInvalidPublicKey(publicKey: String) {
        let error = #expect(throws: CheckoutEncryptor.Error.self) {
            try CheckoutEncryptor.encrypt(card: CheckoutCard(number: "4111111111111111"), publicKey: publicKey)
        }

        #expect(error?.code == .invalidPublicKey)
    }

    // MARK: - Error

    @Test func error_localizedDescription_shouldBeMessage() {
        let error = #expect(throws: CheckoutEncryptor.Error.self) {
            try CheckoutEncryptor.encrypt(card: CheckoutCard(), publicKey: Dummy.publicKey)
        }

        #expect(error?.localizedDescription == error?.message)
    }
}
