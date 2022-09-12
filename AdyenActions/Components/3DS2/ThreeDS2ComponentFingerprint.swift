//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Adyen3DS2
import Foundation

internal extension ThreeDS2Component {
    
    struct Fingerprint: Codable, Equatable { // swiftlint:disable:this explicit_acl
        
        internal let deviceInformation: String
        internal let sdkEphemeralPublicKey: EphemeralPublicKey
        internal let sdkReferenceNumber: String
        internal let sdkApplicationIdentifier: String
        internal let sdkTransactionIdentifier: String
        internal let delegatedAuthenticationSDKOutput: String?
        
        internal init(deviceInformation: String,
                      sdkEphemeralPublicKey: ThreeDS2Component.Fingerprint.EphemeralPublicKey,
                      sdkReferenceNumber: String,
                      sdkApplicationIdentifier: String,
                      sdkTransactionIdentifier: String,
                      delegatedAuthenticationSDKOutput: String?) {
            self.deviceInformation = deviceInformation
            self.sdkEphemeralPublicKey = sdkEphemeralPublicKey
            self.sdkReferenceNumber = sdkReferenceNumber
            self.sdkApplicationIdentifier = sdkApplicationIdentifier
            self.sdkTransactionIdentifier = sdkTransactionIdentifier
            self.delegatedAuthenticationSDKOutput = delegatedAuthenticationSDKOutput
        }
        
        internal init(authenticationRequestParameters: AnyAuthenticationRequestParameters,
                      delegatedAuthenticationSDKOutput: String?) throws {
            let sdkEphemeralPublicKeyData = Data(authenticationRequestParameters.sdkEphemeralPublicKey.utf8)
            let sdkEphemeralPublicKey = try JSONDecoder().decode(EphemeralPublicKey.self, from: sdkEphemeralPublicKeyData)
            
            self.deviceInformation = authenticationRequestParameters.deviceInformation
            self.sdkEphemeralPublicKey = sdkEphemeralPublicKey
            self.sdkReferenceNumber = authenticationRequestParameters.sdkReferenceNumber
            self.sdkApplicationIdentifier = authenticationRequestParameters.sdkApplicationIdentifier
            self.sdkTransactionIdentifier = authenticationRequestParameters.sdkTransactionIdentifier
            self.delegatedAuthenticationSDKOutput = delegatedAuthenticationSDKOutput
        }
        
        internal func withDelegatedAuthenticationSDKOutput(delegatedAuthenticationSDKOutput: String?) -> Fingerprint {
            .init(deviceInformation: deviceInformation,
                  sdkEphemeralPublicKey: sdkEphemeralPublicKey,
                  sdkReferenceNumber: sdkReferenceNumber,
                  sdkApplicationIdentifier: sdkApplicationIdentifier,
                  sdkTransactionIdentifier: sdkTransactionIdentifier,
                  delegatedAuthenticationSDKOutput: delegatedAuthenticationSDKOutput)
        }
        
        private enum CodingKeys: String, CodingKey {
            case deviceInformation = "sdkEncData"
            case sdkEphemeralPublicKey = "sdkEphemPubKey"
            case sdkReferenceNumber
            case sdkApplicationIdentifier = "sdkAppID"
            case sdkTransactionIdentifier = "sdkTransID"
            case delegatedAuthenticationSDKOutput
        }
        
    }
    
}

extension ThreeDS2Component.Fingerprint {
    
    internal struct EphemeralPublicKey: Codable, Equatable {
        
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
