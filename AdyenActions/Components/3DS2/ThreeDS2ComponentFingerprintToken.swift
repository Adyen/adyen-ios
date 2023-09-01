//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension ThreeDS2Component {
    
    struct FingerprintToken: Decodable { // swiftlint:disable:this explicit_acl
        
        let directoryServerIdentifier: String
        let directoryServerPublicKey: String
        let threeDSMessageVersion: String
        let directoryServerRootCertificates: String?
        let delegatedAuthenticationSDKInput: String?
        
        private enum CodingKeys: String, CodingKey {
            case directoryServerIdentifier = "directoryServerId"
            case directoryServerPublicKey
            case threeDSMessageVersion
            case directoryServerRootCertificates
            case delegatedAuthenticationSDKInput
        }
    }
    
}
