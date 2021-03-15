//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An object that provides static methods for encrypting card information and retrieving public keys from the server.
public enum CardEncryptor {
    
    // MARK: - Card Encryption
    
    /// Encrypts a card.
    ///
    /// - Parameters:
    ///   - card: Card containing the data to be encrypted.
    ///   - publicKey: The public key to use for encryption (format "Exponent|Modulus").
    /// - Returns: An encrypted card containing the individually encrypted fields.
    /// - Throws:  `CardEncryptor.Error.encryptionFailed` if the encryption failed,
    ///  maybe because the card public key is an invalid one, or for any other reason.
    /// - Throws:  `CardEncryptor.Error.invalidEncryptionArguments` when trying to encrypt a card with  card number, securityCode,
    /// expiryMonth, and expiryYear, all of them are nil.
    public static func encrypt(card: Card, with publicKey: String) throws -> EncryptedCard {
        guard !card.isEmpty else { throw CardEncryptor.Error.invalidCard }

        var encryptedNumber: String?
        var encryptedCode: String?
        var encryptedMonth: String?
        var encryptedYear: String?

        if let number = card.number {
            encryptedNumber = try encrypt(CardPayload().add(number: number), with: publicKey)
        }
        if let securityCode = card.securityCode {
            encryptedCode = try encrypt(CardPayload().add(securityCode: securityCode), with: publicKey)
        }
        if let expiryMonth = card.expiryMonth {
            encryptedMonth = try encrypt(CardPayload().add(expiryMonth: expiryMonth), with: publicKey)
        }
        if let expiryYear = card.expiryYear {
            encryptedYear = try encrypt(CardPayload().add(expiryYear: expiryYear), with: publicKey)
        }

        return EncryptedCard(number: encryptedNumber,
                             securityCode: encryptedCode,
                             expiryMonth: encryptedMonth,
                             expiryYear: encryptedYear)
    }

    /// Encrypts card number.
    ///
    /// - Parameters:
    ///   - number: The card number
    ///   - publicKey: The public key to use for encryption (format "Exponent|Modulus").
    /// - Returns: An encrypted token containing card number data.
    /// - Throws:  `CardEncryptor.Error.encryptionFailed` if the encryption failed,
    ///  maybe because the card public key is an invalid one, or for any other reason.
    /// - Throws:  `CardEncryptor.Error.invalidEncryptionArguments` when trying to encrypt a card with  card number, securityCode,
    /// expiryMonth, and expiryYear, all of them are nil.
    public static func encrypt(number: String, with publicKey: String) throws -> String {
        guard !number.isEmpty, number.allSatisfy({ $0.isNumber }) else {
            throw Error.invalidNumber
        }
        let payload = CardPayload().add(number: number)
        return try encrypt(payload, with: publicKey)
    }

    /// Encrypts security code.
    ///
    /// - Parameters:
    ///   - securityCode: The card's security code.
    ///   - publicKey: The public key to use for encryption (format "Exponent|Modulus").
    /// - Returns: An encrypted token containing security code data.
    /// - Throws:  `CardEncryptor.Error.encryptionFailed` if the encryption failed,
    ///  maybe because the card public key is an invalid one, or for any other reason.
    /// - Throws:  `CardEncryptor.Error.invalidEncryptionArguments` when trying to encrypt a card with  card number, securityCode,
    /// expiryMonth, and expiryYear, all of them are nil.
    public static func encrypt(securityCode: String, with publicKey: String) throws -> String {
        guard !securityCode.isEmpty, securityCode.allSatisfy({ $0.isNumber }) else {
            throw Error.invalidSecureCode
        }
        let payload = CardPayload().add(securityCode: securityCode)
        return try encrypt(payload, with: publicKey)
    }

    /// Encrypts enspiration month.
    ///
    /// - Parameters:
    ///   - expiryMonth: The expiration month.
    ///   - publicKey: The public key to use for encryption (format "Exponent|Modulus").
    /// - Returns: An encrypted token enspiration month data.
    /// - Throws:  `CardEncryptor.Error.encryptionFailed` if the encryption failed,
    ///  maybe because the card public key is an invalid one, or for any other reason.
    /// - Throws:  `CardEncryptor.Error.invalidEncryptionArguments` when trying to encrypt a card with  card number, securityCode,
    /// expiryMonth, and expiryYear, all of them are nil.
    public static func encrypt(expirationMonth: String, with publicKey: String) throws -> String {
        guard !expirationMonth.isEmpty, expirationMonth.allSatisfy({ $0.isNumber }) else {
            throw Error.invalidExpiryMonth
        }
        let payload = CardPayload().add(expiryMonth: expirationMonth)
        return try encrypt(payload, with: publicKey)
    }

    /// Encrypts enspiration year.
    ///
    /// - Parameters:
    ///   - expiryMonth: The expiration year.
    ///   - publicKey: The public key to use for encryption (format "Exponent|Modulus").
    /// - Returns: An encrypted token containing enspiration year data.
    /// - Throws:  `CardEncryptor.Error.encryptionFailed` if the encryption failed,
    ///  maybe because the card public key is an invalid one, or for any other reason.
    /// - Throws:  `CardEncryptor.Error.invalidEncryptionArguments` when trying to encrypt a card with  card number, securityCode,
    /// expiryMonth, and expiryYear, all of them are nil.
    public static func encrypt(expirationYear: String, with publicKey: String) throws -> String {
        guard !expirationYear.isEmpty, expirationYear.allSatisfy({ $0.isNumber }) else {
            throw Error.invalidExpiryYear
        }
        let payload = CardPayload().add(expiryYear: expirationYear)
        return try encrypt(payload, with: publicKey)
    }
    
    /// Encrypt BIN.
    /// - Parameters:
    ///   - publicKey: The public key to use for encryption (format "Exponent|Modulus").
    ///   - bin: BIN( Bank Identification number) is the first 6 to 12 digits of PAN.
    /// - Returns: An encrypted token containing BIN data.
    /// - Throws:  `CardEncryptor.Error.encryptionFailed` if the encryption failed,
    ///  maybe because the card public key is an invalid one, or for any other reason.
    /// - Throws:  `CardEncryptor.Error.invalidEncryptionArguments` when trying to encrypt a card with  card number, securityCode,
    /// expiryMonth, and expiryYear, all of them are nil.
    public static func encrypt(bin: String, with publicKey: String) throws -> String {
        guard !bin.isEmpty, bin.allSatisfy({ $0.isNumber }) else {
            throw Error.invalidBin
        }
        let payload = BinPayload().add(bin: bin)
        return try encrypt(payload, with: publicKey)
    }

    /// Encrypts a card as a token.
    /// - Parameters:
    ///   - card: Card containing the data to be encrypted.
    ///   - publicKey: The public key to use for encryption (format "Exponent|Modulus").
    /// - Returns: A string token containig encrypted card data.
    /// - Throws:  `CardEncryptor.Error.encryptionFailed` if the encryption failed,
    ///  maybe because the card public key is an invalid one, or for any other reason.
    /// - Throws:  `CardEncryptor.Error.invalidEncryptionArguments` when trying to encrypt a card with  card number, securityCode,
    /// expiryMonth, and expiryYear, all of them are nil.
    public static func encryptToken(from card: Card, with publicKey: String) throws -> String {
        guard !card.isEmpty else { throw CardEncryptor.Error.invalidCard }
        let payload = CardPayload()
            .add(number: card.number)
            .add(securityCode: card.securityCode)
            .add(expiryMonth: card.expiryMonth)
            .add(expiryYear: card.expiryYear)
        return try encrypt(payload, with: publicKey)
    }

    private static func encrypt(_ payload: Payload, with publicKey: String) throws -> String {
        do {
            let unencryptedData = try payload.jsonData()
            return try Cryptor(aes: Cryptor.AES.CCM).encrypt(data: unencryptedData, publicKey: publicKey)
        } catch {
            throw CardEncryptor.Error.encryptionFailed
        }
    }
}

extension CardEncryptor {

    // MARK: - Error

    /// Describes the error that can occur during card encryption and public key fetching.
    public enum Error: Swift.Error, LocalizedError {

        /// Indicates encryption failed  because of invalid card public key or for some other unknown reason.
        case encryptionFailed

        /// Indicates an error when trying to encrypt a card with card number, securityCode,
        /// expiryMonth, expiryYear are nil.
        case invalidCard

        /// Indicates an error when trying to encrypt empty or invalid BIN number.
        case invalidBin

        /// Indicates an error when trying to encrypt empty or invalid expiry year.
        case invalidExpiryYear

        /// Indicates an error when trying to encrypt empty or invalid expiry year.
        case invalidExpiryMonth

        /// Indicates an error when trying to encrypt empty or invalid expiry year.
        case invalidSecureCode

        /// Indicates an error when trying to encrypt empty or invalid expiry year.
        case invalidNumber

        public var errorDescription: String? {
            switch self {
            case .encryptionFailed:
                return "Encryption failed, please check if the public key is a valid."
            case .invalidCard:
                return "Trying to encrypt a card with empty card number, securityCode, expiryMonth or expiryYear"
            case .invalidBin:
                return "Trying to encrypt an empty or invalid BIN"
            case .invalidExpiryYear:
                return "Trying to encrypt empty or invalid expiry year"
            case .invalidExpiryMonth:
                return "Trying to encrypt empty or invalid expiry month"
            case .invalidSecureCode:
                return "Trying to encrypt empty or invalid secure code"
            case .invalidNumber:
                return "Trying to encrypt empty card number"
            }
        }
    }

}
