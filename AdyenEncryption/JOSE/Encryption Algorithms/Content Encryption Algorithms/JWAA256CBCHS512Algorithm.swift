//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import CommonCrypto
import Foundation

internal struct JWAA256CBCHS512Algorithm: JWAEncryptionAlgorithm {
    internal let keyLength: Int = kCCKeySizeAES256 * 2
    
    internal let initializationVectorLength: Int = kCCBlockSizeAES128
    
    internal let name: String = "A256CBC-HS512"
    
    internal func encrypt(input: JWAInput) throws -> JWAOutput {
        guard input.key.count == keyLength else {
            throw EncryptionError.invalidKey
        }
        guard input.initializationVector.count == initializationVectorLength else {
            throw EncryptionError.invalidInitializationVector
        }

        let (aesKey, hmacKey) = deriveKeys(from: input.key)
        
        let operation = CCOperation(kCCEncrypt)
        let option = CCOptions(kCCOptionPKCS7Padding)
        let encryptedPayload = try aesCrypt(operation: operation,
                                            options: option,
                                            keyData: aesKey,
                                            initializationVector: input.initializationVector,
                                            dataIn: input.payload)
        let authenticationTag = try createAuthenticationTag(withAdditionalAuthenticationData: input.additionalAuthenticationData,
                                                            initializationVector: input.initializationVector,
                                                            encryptedPayload: encryptedPayload,
                                                            hmacKey: hmacKey)
        return JWAOutput(encryptedPayload: encryptedPayload, authenticationTag: authenticationTag)
    }
    
    private func deriveKeys(from key: Data) -> (aesKey: Data, hmacKey: Data) {
        let subKeyLength = keyLength / 2
        
        let keyStart: Data.Index = key.startIndex
        let keyMiddle: Data.Index = keyStart.advanced(by: subKeyLength)
        let keyEnd: Data.Index = keyMiddle.advanced(by: subKeyLength)
        
        let hmacKey = key.subdata(in: keyStart..<keyMiddle)
        let aesKey = key.subdata(in: keyMiddle..<keyEnd)
        
        return (aesKey, hmacKey)
    }
    
    private func createAuthenticationTag(withAdditionalAuthenticationData: Data,
                                         initializationVector: Data,
                                         encryptedPayload: Data,
                                         hmacKey: Data) throws -> Data {
        var hmacData = Data()
        hmacData.append(withAdditionalAuthenticationData)
        hmacData.append(initializationVector)
        hmacData.append(encryptedPayload)
        hmacData.append(tagLengthData(forAdditionalAuthenticationData: withAdditionalAuthenticationData))
        
        let hmacDigest = try hmac(data: hmacData, withKey: hmacKey)
        let digestStart = hmacDigest.startIndex
        let digestEnd = digestStart.advanced(by: hmacDigest.count / 2)
        return hmacDigest.subdata(in: digestStart..<digestEnd)
    }
    
    private func tagLengthData(forAdditionalAuthenticationData: Data) -> Data {
        let lengthInBits = UInt64(forAdditionalAuthenticationData.count * 8)
        let bigEndianLength = lengthInBits.bigEndian
        return withUnsafeBytes(of: bigEndianLength) { Data($0) }
    }

}
