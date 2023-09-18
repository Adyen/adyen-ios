//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal extension ThreeDS2Component {
    
    struct FingerprintToken: Decodable { // swiftlint:disable:this explicit_acl
        
        internal let directoryServerIdentifier: String
        internal let directoryServerPublicKey: String
        internal let threeDSMessageVersion: String
        internal let directoryServerRootCertificates: String
        
        private enum CodingKeys: String, CodingKey {
            case directoryServerIdentifier = "directoryServerId"
            case directoryServerPublicKey
            case threeDSMessageVersion
            case directoryServerRootCertificates
        }
    }
    
}
