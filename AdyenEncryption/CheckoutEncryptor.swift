//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A type that provides static methods to encrypt card and bank account details with your public key.
public enum CheckoutEncryptor {

    /// Encrypts each card field that is not `nil` separately.
    ///
    /// - Parameters:
    ///   - card: The card details to encrypt.
    ///   - publicKey: The public key to encrypt with, in the format `Exponent|Modulus`.
    /// - Returns: The encrypted card. A field is `nil` when the same field of `card` is `nil`.
    /// - Throws: ``CheckoutEncryptor/Error`` with code ``CheckoutEncryptor/Error/Code/invalidCard``
    ///   when all the fields of the card are all `nil`,
    ///   ``CheckoutEncryptor/Error/Code/invalidPublicKey`` when the public key is invalid,
    ///   or ``CheckoutEncryptor/Error/Code/encryptionFailed`` when the encryption fails.
    public static func encrypt(card: CheckoutCard, publicKey: String) throws -> CheckoutEncryptedCard {
        guard !card.isEmpty else {
            throw Error(code: .invalidCard, message: "The card has no number, security code, expiry month or expiry year.")
        }

        let key = try makeSecKey(from: publicKey)
        return try CheckoutEncryptedCard(
            number: encryptIfPresent(field: .cardNumber, value: card.number, key: key),
            securityCode: encryptIfPresent(field: .securityCode, value: card.securityCode, key: key),
            expiryMonth: encryptIfPresent(field: .expiryMonth, value: card.expiryMonth, key: key),
            expiryYear: encryptIfPresent(field: .expiryYear, value: card.expiryYear, key: key)
        )
    }

    /// Encrypts a single value.
    ///
    /// The value is not validated, so validate it before you encrypt it.
    ///
    /// - Parameters:
    ///   - field: The field that the value belongs to.
    ///   - value: The value to encrypt.
    ///   - publicKey: The public key to encrypt with, in the format `Exponent|Modulus`.
    /// - Returns: The encrypted value.
    /// - Throws: ``CheckoutEncryptor/Error`` with code ``CheckoutEncryptor/Error/Code/invalidPublicKey``
    ///   when the public key is invalid, or ``CheckoutEncryptor/Error/Code/encryptionFailed`` when the encryption fails.
    public static func encrypt(field: Field, value: String, publicKey: String) throws -> String {
        try encrypt(FieldPayload(field: field, value: value), with: makeSecKey(from: publicKey))
    }
}

extension CheckoutEncryptor {

    /// Uppercase hexadecimal: 5 characters for the exponent and 512 for the modulus of a 2048-bit RSA key.
    private static let publicKeyPattern = #"[0-9A-F]{5}\|[0-9A-F]{512}"#

    /// Checks the format of the public key and creates the RSA key to encrypt with.
    /// - Throws: ``CheckoutEncryptor/Error`` with code ``CheckoutEncryptor/Error/Code/invalidPublicKey``
    ///   when the format is invalid or the key cannot be created.
    internal static func makeSecKey(from publicKey: String) throws -> SecKey {
        let wholeString = publicKey.startIndex..<publicKey.endIndex
        guard publicKey.range(of: publicKeyPattern, options: .regularExpression) == wholeString else {
            throw Error(code: .invalidPublicKey, message: "The public key does not have the expected format.")
        }

        let parts = publicKey.components(separatedBy: "|")
        do {
            return try createSecKey(fromModulus: parts[1], exponent: parts[0])
        } catch {
            throw Error(code: .invalidPublicKey, message: "The public key could not be parsed.", underlyingError: error)
        }
    }

    internal static func encrypt(
        _ payload: FieldPayload,
        with key: SecKey,
        generator: AnyJSONWebEncryptionGenerator = JSONWebEncryptionGenerator()
    ) throws -> String {
        do {
            return try generator.generate(
                withPayload: payload.jsonData(),
                publicRSAKey: key,
                header: .defaultHeader
            ).compactRepresentation
        } catch {
            throw Error(code: .encryptionFailed, message: "The value could not be encrypted.", underlyingError: error)
        }
    }

    private static func encryptIfPresent(field: Field, value: String?, key: SecKey) throws -> String? {
        guard let value else { return nil }
        return try encrypt(FieldPayload(field: field, value: value), with: key)
    }
}
