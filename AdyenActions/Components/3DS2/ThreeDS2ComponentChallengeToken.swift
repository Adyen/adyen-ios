//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2
import Foundation

extension ThreeDS2Component {
    
    struct ChallengeToken: Decodable { // swiftlint:disable:this explicit_acl
        
        let acsReferenceNumber: String
        let acsSignedContent: String
        let acsTransactionIdentifier: String
        let serverTransactionIdentifier: String
        let threeDSRequestorAppURL: URL?
        
        // MARK: - Decoding
        
        private enum CodingKeys: String, CodingKey {
            case acsReferenceNumber
            case acsSignedContent
            case acsTransactionIdentifier = "acsTransID"
            case serverTransactionIdentifier = "threeDSServerTransID"
            case threeDSRequestorAppURL
        }
        
    }
    
}

extension ADYChallengeParameters {
    
    convenience init(from challengeToken: ThreeDS2Component.ChallengeToken, threeDSRequestorAppURL: URL?) { // swiftlint:disable:this explicit_acl
        self.init(serverTransactionIdentifier: challengeToken.serverTransactionIdentifier,
                  threeDSRequestorAppURL: threeDSRequestorAppURL,
                  acsTransactionIdentifier: challengeToken.acsTransactionIdentifier,
                  acsReferenceNumber: challengeToken.acsReferenceNumber,
                  acsSignedContent: challengeToken.acsSignedContent)
    }
    
}
