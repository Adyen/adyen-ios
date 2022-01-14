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
    /// - Throws: `CardEncryptor.Error.encryptionFailed` if the encryption failed,
    ///  maybe because the card public key is an invalid one, or for any other reason.
    /// - Throws: `CardEncryptor.Error.emptyValue` when trying to encrypt an empty or invalid card number
    public static func encrypt(accountNumber: String, with publicKey: String) throws -> String {
        guard !accountNumber.isEmpty, accountNumber.allSatisfy(\.isNumber) else {
            throw CardEncryptor.Error.emptyValue
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
    /// - Throws: `CardEncryptor.Error.encryptionFailed` if the encryption failed,
    ///  maybe because the card public key is an invalid one, or for any other reason.
    /// - Throws: `CardEncryptor.Error.emptyValue` when trying to encrypt an empty or invalid card number
    public static func encrypt(routingNumber: String, with publicKey: String) throws -> String {
        guard !routingNumber.isEmpty, routingNumber.allSatisfy(\.isNumber) else {
            throw CardEncryptor.Error.emptyValue
        }
        let payload = BankPayload().add(routingNumber: routingNumber)
        return try encrypt(payload, with: publicKey)
    }
    
}
