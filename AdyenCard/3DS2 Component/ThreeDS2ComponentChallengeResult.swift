//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2
import Foundation

public extension ThreeDS2Component {
    
    /// Contains the result of a challenge.
    struct ChallengeResult {
        
        /// A boolean value indicating whether the shopper was authenticated.
        public let isAuthenticated: Bool
        
        /// The payload to submit to verify the authentication.
        public let payload: String
        
        internal init(from challengeResult: AnyChallengeResult) throws {
            let payloadData = try JSONSerialization.data(withJSONObject: ["transStatus": challengeResult.transactionStatus],
                                                         options: [])
            
            self.isAuthenticated = challengeResult.transactionStatus == "Y"
            self.payload = payloadData.base64EncodedString()
        }

        internal init(isAuthenticated: Bool) throws {
            let transStatusValue = isAuthenticated ? "Y" : "N"
            let payloadData = try JSONSerialization.data(withJSONObject: ["transStatus": transStatusValue],
                                                         options: [])

            self.isAuthenticated = isAuthenticated
            self.payload = payloadData.base64EncodedString()
        }
        
    }
    
}
