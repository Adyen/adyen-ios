//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2
import Foundation

// MARK: - Card3DS2Authenticator.FingerprintToken

internal extension Card3DS2Authenticator {
    
    struct FingerprintToken: Decodable {
        
        internal let directoryServerIdentifier: String
        internal let directoryServerPublicKey: String
        
        private enum CodingKeys: String, CodingKey {
            case directoryServerIdentifier = "directoryServerId"
            case directoryServerPublicKey
        }
    }
    
}

// MARK: - Card3DS2Authenticator.ChallengeToken

internal extension Card3DS2Authenticator {
    
    struct ChallengeToken: Decodable {
        
        internal let acsReferenceNumber: String
        internal let acsSignedContent: String
        internal let acsTransactionIdentifier: String
        internal let serverTransactionIdentifier: String
        
        // MARK: - Decoding
        
        private enum CodingKeys: String, CodingKey {
            case acsReferenceNumber
            case acsSignedContent
            case acsTransactionIdentifier = "acsTransID"
            case serverTransactionIdentifier = "threeDSServerTransID"
        }
        
    }
    
}

// MARK: - ADYChallengeParameters Helpers

internal extension ADYChallengeParameters {
    
    convenience init(from challengeToken: Card3DS2Authenticator.ChallengeToken) {
        self.init(serverTransactionIdentifier: challengeToken.serverTransactionIdentifier,
                  acsTransactionIdentifier: challengeToken.acsTransactionIdentifier,
                  acsReferenceNumber: challengeToken.acsReferenceNumber,
                  acsSignedContent: challengeToken.acsSignedContent)
    }
    
}
