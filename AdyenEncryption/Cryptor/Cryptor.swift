//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import CommonCrypto
import Foundation

/// :nodoc:
internal struct Cryptor {

    private static let msgSeparator = "$"

    /// :nodoc:
    internal let aes: AES

    private var prefix: String {
        "adyenio_0_\(aes.rawValue)_25" + Cryptor.msgSeparator
    }

    /// Initiate cryptor with selected AES alghoritm
    /// :nodoc:
    internal init(aes: AES) {
        self.aes = aes
    }
    
    /**
     * Encrypts the data with AES-CBC using
     * generated AES256 session key and IV (12)
     * Encrypts the session key with RSA using
     * public key (using Keychain)
     *
     *
     * - Parameters:
     *   - data: Data to be encrypted.
     *   - keyInHex: Public key in Hex with format "Exponent|Modulus"
     *
     * - Returns: Fully composed message in format:
     *   - a prefix
     *   - a separator
     *   - RSA encrypted AES key, base64 encoded
     *   - a separator
     *   - a Payload of iv and cipherText, base64 encoded
     *
     */
    internal func encrypt(data: Data, publicKey keyInHex: String) throws -> String {
        
        //
        var key = [UInt8](repeating: 0, count: kCCKeySizeAES256)
        guard SecRandomCopyBytes(kSecRandomDefault, key.count, &key) == noErr else {
            throw Error.randomGenerationError
        }
        
        // generate a initialisation vector
        var initVector = [UInt8](repeating: 0, count: aes.ivLength)
        guard SecRandomCopyBytes(kSecRandomDefault, initVector.count, &initVector) == noErr else {
            throw Error.randomGenerationError
        }
        
        guard
            case let encryptionResult = self.aesEncrypt(data: data, with: Data(key), initVector: Data(initVector)),
            let cipherText = encryptionResult.cipher
        else { throw Error.aesEncryptionError }
        
        // format of the fully composed message:
        // - a prefix
        // - a separator
        // - RSA encrypted AES key, base64 encoded
        // - a separator
        // - a Payload of iv and cipherText, base64 encoded
        var payload = Data()
        payload.append(contentsOf: initVector)
        payload.append(cipherText)
        payload.append(encryptionResult.atag ?? Data())
        
        if let encryptedKey = try? self.rsaEncrypt(data: Data(key), with: keyInHex) {
            return prefix + encryptedKey.base64EncodedString() + Cryptor.msgSeparator + payload.base64EncodedString()
        }
        
        throw Error.rsaEncryptionError
    }
    
    private func aesEncrypt(data: Data, with key: Data, initVector: Data) -> EncryptionResult {
        aes.encrypt(data: data as NSData, withKey: key as NSData, initVector: initVector as NSData)
    }
    
    private func rsaEncrypt(data: Data, with keyInHex: String) throws -> Data? {
        let tokens = keyInHex.components(separatedBy: "|")
        guard tokens.count == 2 else { return nil }
        
        return try RSA.encrypt(data: data, exponent: tokens[0], modulus: tokens[1])
    }

    internal enum Error: Swift.Error, LocalizedError {
        case randomGenerationError
        case aesEncryptionError
        case rsaEncryptionError

        public var errorDescription: String? {
            switch self {
            case .randomGenerationError:
                return "Error occured while genrating an array of cryptographically secure random bytes."
            case .aesEncryptionError:
                return "Error occured while encryptng data."
            case .rsaEncryptionError:
                return "Error occured while encryptng session key."
            }
        }
    }
}
