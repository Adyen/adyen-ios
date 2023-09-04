//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import CommonCrypto
import Foundation

internal func aesCrypt(operation: CCOperation,
                       options: CCOptions,
                       keyData: Data,
                       initializationVector: Data?,
                       dataIn: Data) throws -> Data {
    let dataOutLength = dataIn.count + kCCBlockSizeAES128
    guard let dataOut = NSMutableData(length: dataOutLength) else {
        throw EncryptionError.encryptionFailed
    }
    let keyData = keyData as NSData
    let dataIn = dataIn as NSData
    let initializationVector = initializationVector as NSData?
    var numBytesOut: size_t = 0
    let algorithm = CCAlgorithm(kCCAlgorithmAES)
    let status: CCCryptorStatus = CCCrypt(operation,
                                          algorithm,
                                          options,
                                          keyData.bytes, keyData.length,
                                          initializationVector?.bytes,
                                          dataIn.bytes, dataIn.length,
                                          dataOut.mutableBytes, dataOut.length,
                                          &numBytesOut)
    guard status == kCCSuccess else {
        throw EncryptionError.encryptionFailed
    }
    let startIndex = dataOut.startIndex
    let endIndex = startIndex.advanced(by: numBytesOut)
    return (dataOut as Data).subdata(in: 0..<endIndex)
}

internal func hmac(data: Data, withKey: Data) throws -> Data {
    guard let dataOut = NSMutableData(length: Int(CC_SHA512_DIGEST_LENGTH)) else {
        throw EncryptionError.unknownError
    }
    let dataIn = data as NSData
    let keyData = withKey as NSData
    CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA512),
           keyData.bytes,
           keyData.length,
           dataIn.bytes,
           dataIn.length,
           dataOut.mutableBytes)
    return dataOut as Data
}

internal func generateRandomData(length: Int) throws -> Data {
    var bytes = [Int8](repeating: 0, count: length)
    let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
    guard status == errSecSuccess else { throw EncryptionError.failedToGenerateRandomData }
    return Data(bytes: bytes, count: length)
}

internal func createSecKey(fromModulus modulus: String, exponent: String) throws -> SecKey {
    guard let modulusHex = modulus.hexadecimal,
          let exponentHex = exponent.hexadecimal else { throw EncryptionError.invalidKey }
    let keyData = generateRSAPublicKey(with: modulusHex, exponent: exponentHex)
    var error: Unmanaged<CFError>?
    let parsedKey = SecKeyCreateWithData(keyData as NSData,
                                         [
                                             kSecAttrKeyType: kSecAttrKeyTypeRSA,
                                             kSecAttrKeyClass: kSecAttrKeyClassPublic
                                         ] as NSDictionary,
                                         &error)
    if let error {
        throw EncryptionError.other(error.takeRetainedValue())
    }
    
    guard let key = parsedKey else { throw EncryptionError.invalidKey }
    return key
}

/// https://github.com/henrinormak/Heimdall/blob/master/Heimdall/Heimdall.swift
internal func generateRSAPublicKey(with modulus: Data, exponent: Data) -> Data {
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
    let bytesArray: [UInt8] = [
        // Container type and size
        [0x30],
        totalLengthOctets,
        
        // Modulus
        [0x02],
        modulusLengthOctets,
        modulusBytes,
        
        // Exponent
        [0x02],
        exponentLengthOctets,
        exponentBytes
        
    ].flatMap { $0 }

    return Data(bytes: bytesArray, count: bytesArray.count)
}
