//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A type that provides static methods for encrypting bank details.
public enum BankDetailsEncryptor: AnyEncryptor {
    
    /// Encrypts bank account number.
    ///
    /// - Parameters:
    ///   - number: The bank account number
    ///   - publicKey: The public key to use for encryption (format "Exponent|Modulus").
    /// - Returns: An encrypted token containing card number data.
    /// - Throws: `EncryptionError.encryptionFailed` if the encryption failed,
    ///  maybe because the card public key is an invalid one, or for any other reason.
    /// - Throws: `BankDetailsEncryptor.Error.invalidAccountNumber` when trying to encrypt an empty or invalid card number
    public static func encrypt(accountNumber: String, with publicKey: String) throws -> String {
        guard !accountNumber.isEmpty, accountNumber.allSatisfy(\.isNumber) else {
            throw Error.invalidAccountNumber
        }
        let payload = BankPayload().add(accountNumber: accountNumber)
        return try encrypt(payload, with: publicKey)
    }
    
    /// Encrypts bank routing number.
    ///
    /// - Parameters:
    ///   - number: The bank account number
    ///   - publicKey: The public key to use for encryption (format "Exponent|Modulus").
    /// - Returns: An encrypted token containing card number data.
    /// - Throws: `EncryptionError.encryptionFailed` if the encryption failed,
    ///  maybe because the card public key is an invalid one, or for any other reason.
    /// - Throws: `BankDetailsEncryptor.Error.invalidRoutingNumber` when trying to encrypt an empty or invalid card number
    public static func encrypt(routingNumber: String, with publicKey: String) throws -> String {
        guard !routingNumber.isEmpty, routingNumber.allSatisfy(\.isNumber) else {
            throw Error.invalidRoutingNumber
        }
        let payload = BankPayload().add(routingNumber: routingNumber)
        return try encrypt(payload, with: publicKey)
    }
}

extension BankDetailsEncryptor {
    
    /// Describes the errors that can occur during bank details encryption.
    public enum Error: LocalizedError {
        /// Indicates an error when trying to encrypt empty or invalid bank account number.
        case invalidAccountNumber
        
        /// Indicates an error when trying to encrypt empty or invalid routing number.
        case invalidRoutingNumber
        
        /// :nodoc:
        public var errorDescription: String? {
            switch self {
            case .invalidAccountNumber:
                return "Trying to encrypt empty or invalid account number"
            case .invalidRoutingNumber:
                return "Trying to encrypt empty or invalid routing number"
            }
        }
    }
}
