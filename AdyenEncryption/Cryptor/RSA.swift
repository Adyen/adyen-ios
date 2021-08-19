//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import Security

extension Cryptor {
    
    /// Set of helpers for RSA encryption.
    internal enum RSA {

        internal static let keySizeInBits = 2048

        /**
         * Encrypt with RSA public key
         *
         * - Parameters:
         *   - data: The data to encrypt.
         *   - exponent: Modulus of the public key.
         *   - modulus: Exponent of the public key.
         *
         *  - Returns
         *      Encrypted data or nil if modulus and exponent is invalid.
         */
        internal static func encrypt(data: Data, exponent: String, modulus: String) throws -> Data? {
            guard let modulusHex = modulus.hexadecimal, let exponentHex = exponent.hexadecimal else { return nil }

            let pubKeyData = generateRSAPublicKey(with: modulusHex, exponent: exponentHex)
            return try self.encrypt(original: data, publicKey: pubKeyData)
        }

        private static func encrypt(original: Data, publicKey: Data) throws -> Data? {
            var error: Unmanaged<CFError>?

            let attributes: [String: Any] = [
                kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                kSecAttrKeySizeInBits as String: RSA.keySizeInBits
            ]

            if let secKey = SecKeyCreateWithData(publicKey as CFData, attributes as CFDictionary, nil),
               let encrypted = SecKeyCreateEncryptedData(secKey, .rsaEncryptionPKCS1, original as CFData, &error) {
                return encrypted as NSData as Data
            }

            if let err: Swift.Error = error?.takeRetainedValue() {
                throw err
            }
            return nil
        }
    }
}
