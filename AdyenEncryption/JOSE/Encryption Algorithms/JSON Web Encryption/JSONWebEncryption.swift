//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct JSONWebEncryption {
    struct Header: Encodable {
        
        static let defaultHeader: Header = .init(contentEncryptionAlgorithm: .AESCBC,
                                                 keyEncryptionAlgorithm: .rsaOAEP256)
        
        let contentEncryptionAlgorithm: ContentEncryptionAlgorithm
        
        let keyEncryptionAlgorithm: KeyEncryptionAlgorithm
        
        let version: String = "1"
        
        enum KeyEncryptionAlgorithm: String, Encodable {
            case rsaOAEP256 = "RSA-OAEP-256"
            
            var algorithm: RSAAlgorithm {
                switch self {
                case .rsaOAEP256:
                    return RSAOAEP256Algorithm()
                }
            }
        }
        
        enum ContentEncryptionAlgorithm: String, Encodable {
            case AESCBC = "A256CBC-HS512"
            
            var algorithm: JWAEncryptionAlgorithm {
                switch self {
                case .AESCBC:
                    return JWAA256CBCHS512Algorithm()
                }
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case contentEncryptionAlgorithm = "enc"
            case keyEncryptionAlgorithm = "alg"
            case version
        }
    }
    
    let header: Header
    
    let encryptedKey: Data
    
    let encryptedPayload: Data
    
    let initializationVector: Data
    
    let authenticationTag: Data
    
    let compactRepresentation: String
    
    init(header: Header,
         encryptedKey: Data,
         encryptedPayload: Data,
         initializationVector: Data,
         authenticationTag: Data) throws {
        self.header = header
        self.encryptedKey = encryptedKey
        self.encryptedPayload = encryptedPayload
        self.initializationVector = initializationVector
        self.authenticationTag = authenticationTag
        self.compactRepresentation = try [JSONEncoder().encode(header).base64URLString(),
                                          encryptedKey.base64URLString(),
                                          initializationVector.base64URLString(),
                                          encryptedPayload.base64URLString(),
                                          authenticationTag.base64URLString()].joined(separator: ".")
    }

}
