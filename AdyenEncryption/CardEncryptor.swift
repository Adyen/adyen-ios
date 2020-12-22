//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An object that provides static methods for encrypting card information and retrieving public keys from the server.
public enum CardEncryptor {
    
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
    
    /// Encrypt BIN.
    /// - Parameters:
    ///   - publicKey: The public key to use for encryption (format "Exponent|Modulus").
    ///   - bin: BIN( Bank Identification number) is the first 6 to 12 digits of PAN.
    public static func encryptedBin(for bin: String, publicKey: String) throws -> String {
        guard !bin.isEmpty, bin.allSatisfy({ $0.isNumber }) else {
            throw Error.invalidBin
        }
        
        let payload = try JSONEncoder().encode(Bin(value: bin))
        do {
            if #available(iOS 13.0, *) {
                return try Cryptor(aes: .GCM).encrypt(data: payload, publicKey: publicKey)
            } else {
                return try Cryptor(aes: .CCM).encrypt(data: payload, publicKey: publicKey)
            }
        } catch {
            throw Error.encryptionFailed
        }
    }
    
    // MARK: - Error
    
    /// Describes the error that can occur during card encryption and public key fetching.
    public enum Error: Swift.Error, LocalizedError {
        
        /// Indicates encryption failed  because of invalid card public key or for some other unknown reason.
        case encryptionFailed

        /// Indicates an error when trying to encrypt a card with  card number, securityCode,
        /// expiryMonth, expiryYear, and holderName, all of them are nil.
        case invalidEncryptionArguments
        
        /// Indicates an error when trying to encrypt empty or invalid BIN number.
        case invalidBin
        
        public var errorDescription: String? {
            switch self {
            case .encryptionFailed:
                return "Encryption failed, please check if the public key is a valid one."
            case .invalidEncryptionArguments:
                // swiftlint:disable:next line_length
                return "Trying to encrypt a card with card number, securityCode, expiryMonth, expiryYear, and holderName, all of them are nil"
            case .invalidBin:
                return "Trying to encrypt an empty or invalid BIN"
            }
        }
    }
}

extension CardEncryptor {

    private struct Bin: Encodable {
        /// The card BIN number.
        public let value: String

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .value)

            let timestampString = ISO8601DateFormatter().string(from: Date())
            try container.encode(timestampString, forKey: .timestamp)
        }

        private enum CodingKeys: String, CodingKey {
            case value = "binValue"
            case timestamp = "generationtime"
        }

    }
    
}

public extension CardEncryptor {
    
    /// Contains the information of a card that is yet to be encrypted.
    struct Card: Encodable {
        /// The card number.
        public var number: String?

        /// The card's security code.
        public var securityCode: String?

        /// The month the card expires.
        public var expiryMonth: String?

        /// The year the card expires.
        public var expiryYear: String?

        internal var holder: String?

        internal var generationDate: Date?

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

        public func jsonData() -> Data? {
            return try? JSONEncoder().encode(self)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            if let number = number {
                try container.encode(number, forKey: .number)
            }
            if let holder = holder {
                try container.encode(holder, forKey: .holder)
            }
            if let securityCode = securityCode {
                try container.encode(securityCode, forKey: .securityCode)
            }
            if let expiryMonth = expiryMonth {
                try container.encode(expiryMonth, forKey: .expiryMonth)
            }
            if let expiryYear = expiryYear {
                try container.encode(expiryYear, forKey: .expiryYear)
            }
            
            if let generationDate = generationDate {
                let timestampString = ISO8601DateFormatter().string(from: generationDate)
                try container.encode(timestampString, forKey: .generationDate)
            }
        }

        private enum CodingKeys: String, CodingKey {
            case number
            case holder = "holderName"
            case securityCode = "cvc"
            case expiryMonth
            case expiryYear
            case generationDate = "generationtime"
        }
    }

}
