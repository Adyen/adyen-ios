//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import CommonCrypto
import Foundation

internal enum Cryptor {
    
    private static let ivLength = 12
    private static var msgPrefix = "adyenan0_1_1"
    private static let msgSeparator = "$"
    
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
    internal static func encrypt(data: Data, publicKey keyInHex: String) throws -> String {
        
        //
        var key = [UInt8](repeating: 0, count: kCCKeySizeAES256)
        guard SecRandomCopyBytes(kSecRandomDefault, key.count, &key) == noErr else {
            throw Error.randomGenerationError
        }
        
        // generate a initialisation vector
        var initVector = [UInt8](repeating: 0, count: ivLength)
        guard SecRandomCopyBytes(kSecRandomDefault, initVector.count, &initVector) == noErr else {
            throw Error.randomGenerationError
        }
        
        guard
            let cipherText = self.aesEncrypt(data: data, with: Data(key), initVector: Data(initVector))
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
        
        let prefix = msgPrefix.isEmpty ? "" : msgPrefix.appending(msgSeparator)
        
        if let encryptedKey = self.rsaEncrypt(data: Data(key), with: keyInHex) {
            return prefix + encryptedKey.base64EncodedString() + msgSeparator + payload.base64EncodedString()
        }
        
        throw Error.rsaEncryptionError
    }
    
    private static func aesEncrypt(data: Data, with key: Data, initVector: Data) -> Data? {
        AES.encrypt(data: data, withKey: key, initVector: initVector)
    }
    
    private static func rsaEncrypt(data: Data, with keyInHex: String) -> Data? {
        let tokens = keyInHex.components(separatedBy: "|")
        guard tokens.count == 2 else { return nil }
        
        return RSA.encrypt(data: data, exponent: tokens[0], modulus: tokens[1])
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
