//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2
import Foundation

internal extension ThreeDS2Component {
    
    struct Fingerprint: Encodable { // swiftlint:disable:this explicit_acl
        
        private let deviceInformation: String?
        private let sdkEphemeralPublicKey: EphemeralPublicKey?
        private let sdkReferenceNumber: String?
        private let sdkApplicationIdentifier: String?
        private let sdkTransactionIdentifier: String?
        internal let threeDS2SDKError: String?

        internal init(authenticationRequestParameters: AnyAuthenticationRequestParameters) throws {
            let sdkEphemeralPublicKeyData = Data(authenticationRequestParameters.sdkEphemeralPublicKey.utf8)
            let sdkEphemeralPublicKey = try JSONDecoder().decode(EphemeralPublicKey.self, from: sdkEphemeralPublicKeyData)
            
            self.deviceInformation = authenticationRequestParameters.deviceInformation
            self.sdkEphemeralPublicKey = sdkEphemeralPublicKey
            self.sdkReferenceNumber = authenticationRequestParameters.sdkReferenceNumber
            self.sdkApplicationIdentifier = authenticationRequestParameters.sdkApplicationIdentifier
            self.sdkTransactionIdentifier = authenticationRequestParameters.sdkTransactionIdentifier
            self.threeDS2SDKError = nil
        }
        
        internal init(threeDS2SDKError: String) {
            self.threeDS2SDKError = threeDS2SDKError
            
            self.deviceInformation = nil
            self.sdkEphemeralPublicKey = nil
            self.sdkReferenceNumber = nil
            self.sdkApplicationIdentifier = nil
            self.sdkTransactionIdentifier = nil
        }

        private enum CodingKeys: String, CodingKey {
            case deviceInformation = "sdkEncData"
            case sdkEphemeralPublicKey = "sdkEphemPubKey"
            case sdkReferenceNumber
            case sdkApplicationIdentifier = "sdkAppID"
            case sdkTransactionIdentifier = "sdkTransID"
            case threeDS2SDKError
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
