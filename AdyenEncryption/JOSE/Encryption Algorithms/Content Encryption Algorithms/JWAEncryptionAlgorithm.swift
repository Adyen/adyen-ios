//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal protocol JWAEncryptionAlgorithm {
    
    var keyLength: Int { get }
    
    var initializationVectorLength: Int { get }
    
    var name: String { get }
    
    func encrypt(input: JWAInput) throws -> JWAOutput
}

internal struct JWAOutput {
    
    internal let encryptedPayload: Data
    
    internal let authenticationTag: Data
}

internal struct JWAInput {
    
    internal let payload: Data
    
    internal let key: Data
    
    internal let initializationVector: Data
    
    internal let additionalAuthenticationData: Data
}

/// Indicates an error during encryption.
public enum EncryptionError: LocalizedError {
    /// Key is invalid.
    case invalidKey
    
    /// Initialization vector: is invalid
    case invalidInitializationVector
    
    /// Encryption failed
    case encryptionFailed
    
    /// Unknown error
    case unknownError
    
    /// Failed to generate random data
    case failedToGenerateRandomData
    
    /// Invalid base64 string
    case invalidBase64
    
    /// Any other error
    case other(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidKey:
            return "Key is invalid."
        case .invalidInitializationVector:
            return "Initialization vector: is invalid."
        case .encryptionFailed:
            return "Encryption failed."
        case .failedToGenerateRandomData:
            return "Failed to generate random data"
        case .invalidBase64:
            return "Invalid base64 string."
        case .unknownError:
            return "Unknown error."
        case let .other(error):
            return error.localizedDescription
        }
    }
}
