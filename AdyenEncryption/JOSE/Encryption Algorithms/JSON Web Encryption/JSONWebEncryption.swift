//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal struct JSONWebEncryption {
    internal struct Header: Encodable {
        
        internal static let defaultHeader: Header = .init(contentEncryptionAlgorithm: .AESCBC,
                                                          keyEncryptionAlgorithm: .rsaOAEP256)
        
        internal let contentEncryptionAlgorithm: ContentEncryptionAlgorithm
        
        internal let keyEncryptionAlgorithm: KeyEncryptionAlgorithm
        
        internal let version: String = "1"
        
        internal enum KeyEncryptionAlgorithm: String, Encodable {
            case rsaOAEP256 = "RSA-OAEP-256"
            
            internal var algorithm: RSAAlgorithm {
                switch self {
                case .rsaOAEP256:
                    return RSAOAEP256Algorithm()
                }
            }
        }
        
        internal enum ContentEncryptionAlgorithm: String, Encodable {
            case AESCBC = "A256CBC-HS512"
            
            internal var algorithm: JWAEncryptionAlgorithm {
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
    
    internal let header: Header
    
    internal let encryptedKey: Data
    
    internal let encryptedPayload: Data
    
    internal let initializationVector: Data
    
    internal let authenticationTag: Data
    
    internal let compactRepresentation: String
    
    internal init(header: Header,
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
