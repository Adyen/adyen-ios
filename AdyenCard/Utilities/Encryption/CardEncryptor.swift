//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An object that provides static methods for encrypting card information and retrieving public keys from the server.
public enum CardEncryptor {
    /// Contains the information of a card that is yet to be encrypted.
    public struct Card {
        /// The card number.
        public var number: String?
        
        /// The card's security code.
        public var securityCode: String?
        
        /// The month the card expires.
        public var expiryMonth: String?
        
        /// The year the card expires.
        public var expiryYear: String?
        
        /// :nodoc:
        public init(number: String? = nil, securityCode: String? = nil, expiryMonth: String? = nil, expiryYear: String? = nil) {
            self.number = number
            self.securityCode = securityCode
            self.expiryMonth = expiryMonth
            self.expiryYear = expiryYear
        }
        
        internal var isEmpty: Bool {
            return [number, securityCode, expiryYear, expiryMonth].allSatisfy { $0 == nil }
        }
        
    }
    
    /// Contains encrypted card information.
    public struct EncryptedCard {
        /// The encrypted card number.
        public let number: String?
        
        /// The card's encrypted security code.
        public let securityCode: String?
        
        /// The encrypted month the card expires.
        public let expiryMonth: String?
        
        /// The encrypted year the card expires.
        public let expiryYear: String?
        
    }
    
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
    public static func encryptedCard(for card: Card, publicKey: String) throws -> EncryptedCard {
        guard !card.isEmpty else {
            throw CardEncryptor.Error.invalidEncryptionArguments
        }
        let generationDate = Date()
        let number = try card.encryptedNumber(publicKey: publicKey, date: generationDate)
        let expiryYear = try card.encryptedExpiryYear(publicKey: publicKey, date: generationDate)
        let expiryMonth = try card.encryptedExpiryMonth(publicKey: publicKey, date: generationDate)
        let securityCode = try card.encryptedSecurityCode(publicKey: publicKey, date: generationDate)
        
        return EncryptedCard(number: number,
                             securityCode: securityCode,
                             expiryMonth: expiryMonth,
                             expiryYear: expiryYear)
    }
    
    /// Encrypts a card.
    ///
    /// - Parameters:
    ///   - card: Card containing the data to be encrypted.
    ///   - holderName: The cardholder's name.
    ///   - publicKey: The public key to use for encryption (format "Exponent|Modulus").
    /// - Returns: A string representing the encrypted card.
    /// - Throws:  `CardEncryptor.Error.encryptionFailed` if the encryption failed,
    ///  maybe because the card public key is an invalid one, or for any other reason.
    /// - Throws:  `CardEncryptor.Error.invalidEncryptionArguments` when trying to encrypt a card with  card number, securityCode,
    /// expiryMonth, expiryYear, and holderName, all of them are nil.
    /// - Throws:  `CardEncryptor.Error.unknown` if encryption failed for an unknown reason.
    public static func encryptedToken(for card: Card, holderName: String?, publicKey: String) throws -> String {
        guard let cardToken = try card.encryptedToToken(publicKey: publicKey, holderName: holderName) else {
            // This should never happen,
            // because card.encryptedToToken(publicKey:holderName:) will throw an error if the generated token is some how nil,
            // before reaching here.
            throw Error.unknown
        }
        
        return cardToken
    }
    
    // MARK: - Delete RSA
    
    /// :nodoc:
    internal static func cleanPublicKeys(publicKeyToken: String) {
        ObjC_CardEncryptor.deleteRSAPublicKey(publicKeyToken)
    }
    
    // MARK: - Error
    
    /// Describes the error that can occur during card encryption and public key fetching.
    public enum Error: Swift.Error, LocalizedError {
        /// Indicates an unknown error occurred.
        case unknown
        /// Indicates encryption failed  because of invalid card public key or for some other unknown reason.
        case encryptionFailed
        /// Indicates an error when trying to encrypt a card with  card number, securityCode,
        /// expiryMonth, expiryYear, and holderName, all of them are nil.
        case invalidEncryptionArguments
        
        public var errorDescription: String? {
            switch self {
            case .encryptionFailed:
                return "Encryption failed, please check if the public key is a valid one."
            case .invalidEncryptionArguments:
                // swiftlint:disable:next line_length
                return "Trying to encrypt a card with card number, securityCode, expiryMonth, expiryYear, and holderName, all of them are nil"
            case .unknown:
                return "Unknow Error"
            }
        }
    }
}
