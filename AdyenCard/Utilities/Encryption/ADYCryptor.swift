//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import CommonCrypto
import Foundation

internal final class ADYCryptor {
    
    private static let ivLength = 12
    private static var msgPrefix = "adyenan0_1_1"
    private static let msgSeparator = "$"
    
    /**
     *  Sets encoded message prefix
     *
     *  @param prefix Prefix string, default: ""
     */
    internal static func setMsgPrefix(prefix: String) {
        msgPrefix = prefix
    }
    
    /**
     *  Encrypts the data with AES-CBC using
     *  generated AES256 session key and IV (12)
     *  Encrypts the session key with RSA using
     *  public key (using Keychain)
     *
     *  @param data     data to be encrypted
     *  @param keyInHex Public key in Hex with format "Exponent|Modulus"
     *
     *  @return Fully composed message in format:
     *    - a prefix
     *    - a separator
     *    - RSA encrypted AES key, base64 encoded
     *    - a separator
     *    - a Payload of iv and cipherText, base64 encoded
     *
     *  @see `setMsgPrefix:`
     *  @see `setMsgSeparator:`
     */
    internal static func encrypt(data: Data, publicKey keyInHex: String) -> String? {
        
        // generate a unique AES key and (later) encrypt it with the public RSA key of the merchant
        var key = [UInt8](repeating: 0, count: kCCKeySizeAES256)
        guard SecRandomCopyBytes(kSecRandomDefault, key.count, &key) == noErr else {
            return nil
        }
        
        // generate a nonce
        var initVector = [UInt8](repeating: 0, count: ivLength)
        guard SecRandomCopyBytes(kSecRandomDefault, initVector.count, &initVector) == noErr else {
            return nil
        }
        
        guard let cipherText = self.aesEncrypt(data: data,
                                               with: Data(key),
                                               initVector: Data(initVector)) else {
            return nil
        }
        
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
        
        return nil
    }
    
    internal static func aesEncrypt(data: Data, with key: Data, initVector: Data) -> Data? {
        return ADYAESCCMCryptor.encrypt(data, withKey: key, iv: initVector)
    }
    
    internal static func rsaEncrypt(data: Data, with keyInHex: String) -> Data? {
        return ADYRSACryptor.encrypt(data, withKeyInHex: keyInHex)
    }
}

extension String {
    
    internal func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        
        var keyData = Data()
        keyData.append(contentsOf: digest)
        return keyData.base64EncodedString()
    }
    
    internal var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        var string = self
        if string.count % 2 == 1 {
            string.insert("0", at: startIndex)
        }
        
        guard let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive) else { return nil }
        regex.enumerateMatches(in: string, range: NSRange(startIndex..., in: string)) { match, _, _ in
            let byteString = (string as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard !data.isEmpty else { return nil }
        
        return data
    }
    
}
