//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Adyen3DS2
import Foundation

extension ThreeDS2Component {
    
    struct Fingerprint: Codable, Equatable { // swiftlint:disable:this explicit_acl
        let deviceInformation: String?
        let sdkEphemeralPublicKey: EphemeralPublicKey?
        let sdkReferenceNumber: String?
        let sdkApplicationIdentifier: String?
        let sdkTransactionIdentifier: String?
        let delegatedAuthenticationSDKOutput: String?
        let threeDS2SDKError: String?
        
        init(deviceInformation: String?,
             sdkEphemeralPublicKey: ThreeDS2Component.Fingerprint.EphemeralPublicKey?,
             sdkReferenceNumber: String?,
             sdkApplicationIdentifier: String?,
             sdkTransactionIdentifier: String?,
             delegatedAuthenticationSDKOutput: String?,
             threeDS2SDKError: String?) {
            self.deviceInformation = deviceInformation
            self.sdkEphemeralPublicKey = sdkEphemeralPublicKey
            self.sdkReferenceNumber = sdkReferenceNumber
            self.sdkApplicationIdentifier = sdkApplicationIdentifier
            self.sdkTransactionIdentifier = sdkTransactionIdentifier
            self.delegatedAuthenticationSDKOutput = delegatedAuthenticationSDKOutput
            self.threeDS2SDKError = threeDS2SDKError
        }
        
        init(threeDS2SDKError: String) {
            self.threeDS2SDKError = threeDS2SDKError
            
            self.deviceInformation = nil
            self.sdkEphemeralPublicKey = nil
            self.sdkReferenceNumber = nil
            self.sdkApplicationIdentifier = nil
            self.sdkTransactionIdentifier = nil
            self.delegatedAuthenticationSDKOutput = nil
        }
        
        init(authenticationRequestParameters: AnyAuthenticationRequestParameters,
             delegatedAuthenticationSDKOutput: String?) throws {
            let sdkEphemeralPublicKeyData = Data(authenticationRequestParameters.sdkEphemeralPublicKey.utf8)
            let sdkEphemeralPublicKey = try JSONDecoder().decode(EphemeralPublicKey.self, from: sdkEphemeralPublicKeyData)
            
            self.deviceInformation = authenticationRequestParameters.deviceInformation
            self.sdkEphemeralPublicKey = sdkEphemeralPublicKey
            self.sdkReferenceNumber = authenticationRequestParameters.sdkReferenceNumber
            self.sdkApplicationIdentifier = authenticationRequestParameters.sdkApplicationIdentifier
            self.sdkTransactionIdentifier = authenticationRequestParameters.sdkTransactionIdentifier
            self.delegatedAuthenticationSDKOutput = delegatedAuthenticationSDKOutput
            self.threeDS2SDKError = nil
        }
        
        func withDelegatedAuthenticationSDKOutput(delegatedAuthenticationSDKOutput: String?) -> Fingerprint {
            .init(deviceInformation: deviceInformation,
                  sdkEphemeralPublicKey: sdkEphemeralPublicKey,
                  sdkReferenceNumber: sdkReferenceNumber,
                  sdkApplicationIdentifier: sdkApplicationIdentifier,
                  sdkTransactionIdentifier: sdkTransactionIdentifier,
                  delegatedAuthenticationSDKOutput: delegatedAuthenticationSDKOutput,
                  threeDS2SDKError: threeDS2SDKError)
        }
        
        private enum CodingKeys: String, CodingKey {
            case deviceInformation = "sdkEncData"
            case sdkEphemeralPublicKey = "sdkEphemPubKey"
            case sdkReferenceNumber
            case sdkApplicationIdentifier = "sdkAppID"
            case sdkTransactionIdentifier = "sdkTransID"
            case delegatedAuthenticationSDKOutput
            case threeDS2SDKError
        }
        
    }
    
}

extension ThreeDS2Component.Fingerprint {
    
    struct EphemeralPublicKey: Codable, Equatable {
        
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
