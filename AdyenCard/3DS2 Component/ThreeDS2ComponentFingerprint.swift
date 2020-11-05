//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2
import Foundation

internal extension ThreeDS2Component {
    
    struct Fingerprint: Encodable { // swiftlint:disable:this explicit_acl
        
        private let deviceInformation: String
        private let sdkEphemeralPublicKey: EphemeralPublicKey
        private let sdkReferenceNumber: String
        private let sdkApplicationIdentifier: String
        private let sdkTransactionIdentifier: String
        
        internal init(authenticationRequestParameters: AnyAuthenticationRequestParameters) throws {
            let sdkEphemeralPublicKeyData = Data(authenticationRequestParameters.sdkEphemeralPublicKey.utf8)
            let sdkEphemeralPublicKey = try JSONDecoder().decode(EphemeralPublicKey.self, from: sdkEphemeralPublicKeyData)
            
            self.deviceInformation = authenticationRequestParameters.deviceInformation
            self.sdkEphemeralPublicKey = sdkEphemeralPublicKey
            self.sdkReferenceNumber = authenticationRequestParameters.sdkReferenceNumber
            self.sdkApplicationIdentifier = authenticationRequestParameters.sdkApplicationIdentifier
            self.sdkTransactionIdentifier = authenticationRequestParameters.sdkTransactionIdentifier
        }
        
        private enum CodingKeys: String, CodingKey {
            case deviceInformation = "sdkEncData"
            case sdkEphemeralPublicKey = "sdkEphemPubKey"
            case sdkReferenceNumber
            case sdkApplicationIdentifier = "sdkAppID"
            case sdkTransactionIdentifier = "sdkTransID"
        }
        
    }
    
}

extension ThreeDS2Component.Fingerprint {
    
    internal struct EphemeralPublicKey: Codable {
        
        private let keyType: String
        private let curve: String
        private let x: String // swiftlint:disable:this identifier_name
        private let y: String // swiftlint:disable:this identifier_name
        
        private enum CodingKeys: String, CodingKey {
            case keyType = "kty"
            case curve = "crv"
            case x // swiftlint:disable:this identifier_name
            case y // swiftlint:disable:this identifier_name
        }
        
    }
    
}
