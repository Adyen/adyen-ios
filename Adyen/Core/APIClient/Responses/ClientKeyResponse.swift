//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// :nodoc:
public struct ClientKeyResponse: Response {
    
    /// The card public key
    public let cardPublicKey: String
    
    /// :nodoc:
    internal init(cardPublicKey: String) {
        self.cardPublicKey = cardPublicKey
    }
    
    /// :nodoc:
    internal enum CodingKeys: String, CodingKey {
        case cardPublicKey = "publicKey"
    }
}
