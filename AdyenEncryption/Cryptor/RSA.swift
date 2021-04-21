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

            let pubKeyData = self.generateRSAPublicKey(with: modulusHex, exponent: exponentHex)
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

        /// https://github.com/henrinormak/Heimdall/blob/master/Heimdall/Heimdall.swift
        private static func generateRSAPublicKey(with modulus: Data, exponent: Data) -> Data {
            var modulusBytes = modulus.asBytes
            let exponentBytes = exponent.asBytes

            // Make sure modulus starts with a 0x00
            if let prefix = modulusBytes.first, prefix != 0x00 {
                modulusBytes.insert(0x00, at: 0)
            }

            // Lengths
            let modulusLengthOctets = modulusBytes.count.encodedOctets()
            let exponentLengthOctets = exponentBytes.count.encodedOctets()

            // Total length is the sum of components + types
            let totalLengthOctets = (modulusLengthOctets.count + modulusBytes.count +
                exponentLengthOctets.count + exponentBytes.count + 2).encodedOctets()

            // Combine the two sets of data into a single container
            var builder: [CUnsignedChar] = []
            let data = NSMutableData()

            // Container type and size
            builder.append(0x30)
            builder.append(contentsOf: totalLengthOctets)
            data.append(builder, length: builder.count)
            builder.removeAll(keepingCapacity: false)

            // Modulus
            builder.append(0x02)
            builder.append(contentsOf: modulusLengthOctets)
            data.append(builder, length: builder.count)
            builder.removeAll(keepingCapacity: false)
            data.append(modulusBytes, length: modulusBytes.count)

            // Exponent
            builder.append(0x02)
            builder.append(contentsOf: exponentLengthOctets)
            data.append(builder, length: builder.count)
            data.append(exponentBytes, length: exponentBytes.count)

            return Data(bytes: data.bytes, count: data.length)
        }
    }
}
