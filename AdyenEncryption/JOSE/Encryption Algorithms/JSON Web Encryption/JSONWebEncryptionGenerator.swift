//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal protocol AnyJSONWebEncryptionGenerator {
    func generate(withPayload: Data,
                  publicRSAKey: SecKey,
                  header: JSONWebEncryption.Header) throws -> JSONWebEncryption
}

internal struct JSONWebEncryptionGenerator: AnyJSONWebEncryptionGenerator {
    internal func generate(withPayload: Data,
                           publicRSAKey: SecKey,
                           header: JSONWebEncryption.Header) throws -> JSONWebEncryption {
        let keyEncryptionAlgorithm = header.keyEncryptionAlgorithm.algorithm
        let contentEncryptionAlgorithm = header.contentEncryptionAlgorithm.algorithm
        
        let contentEncryptionKey = try generateRandomData(length: contentEncryptionAlgorithm.keyLength)
        let encryptedKey = try keyEncryptionAlgorithm.encrypt(contentEncryptionKey, withKey: publicRSAKey)
        
        let encodedHeader = try JSONEncoder().encode(header)
        
        let initializationVector = try generateRandomData(length: contentEncryptionAlgorithm.initializationVectorLength)
        guard let additionalAuthenticationData = encodedHeader.base64URLString().data(using: .ascii) else {
            throw EncryptionError.encryptionFailed
        }
        
        let contentEncryptionInput = JWAInput(payload: withPayload,
                                              key: contentEncryptionKey,
                                              initializationVector: initializationVector,
                                              additionalAuthenticationData: additionalAuthenticationData)
        let contentEncryptionOutput = try contentEncryptionAlgorithm.encrypt(input: contentEncryptionInput)
        
        return JSONWebEncryption(encodedHeader: encodedHeader,
                                 encryptedKey: encryptedKey,
                                 encryptedPayload: contentEncryptionOutput.encryptedPayload,
                                 initializationVector: initializationVector,
                                 authenticationTag: contentEncryptionOutput.authenticationTag)
    }
}
