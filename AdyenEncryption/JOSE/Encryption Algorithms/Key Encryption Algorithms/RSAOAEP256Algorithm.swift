//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal protocol RSAAlgorithm {
    func encrypt(_ payload: Data, withKey key: SecKey) throws -> Data
}

internal struct RSAOAEP256Algorithm: RSAAlgorithm {
    internal func encrypt(_ payload: Data, withKey key: SecKey) throws -> Data {
        var error: Unmanaged<CFError>?
        
        let cipherText = SecKeyCreateEncryptedData(key,
                                                   .rsaEncryptionOAEPSHA256,
                                                   payload as CFData,
                                                   &error)
        
        if let error {
            throw EncryptionError.other(error.takeRetainedValue())
        }
        
        guard let cipherResult = cipherText else { throw EncryptionError.encryptionFailed }
        
        return cipherResult as Data
    }
    
}
