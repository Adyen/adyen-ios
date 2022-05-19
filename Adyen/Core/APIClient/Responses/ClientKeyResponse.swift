//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

@_spi(AdyenInternal)
public struct ClientKeyResponse: Response {
    
    /// The card public key
    public let cardPublicKey: String
    
    internal init(cardPublicKey: String) {
        self.cardPublicKey = cardPublicKey
    }
    
    internal enum CodingKeys: String, CodingKey {
        case cardPublicKey = "publicKey"
    }
}
