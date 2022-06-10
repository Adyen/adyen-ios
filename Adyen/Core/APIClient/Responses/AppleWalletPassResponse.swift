//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

@_spi(AdyenInternal)
public struct AppleWalletPassResponse: Response {

    public let passData: Data

    public init(passBase64String: String) throws {
        guard let passData = Data(base64Encoded: passBase64String) else {
            throw AppleWalletError.failedToAddToAppleWallet
        }
        self.passData = passData
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let passBase64String = try container.decode(String.self, forKey: .passBase64String)
        
        guard let passData = Data(base64Encoded: passBase64String) else {
            throw AppleWalletError.failedToAddToAppleWallet
        }
        
        self.passData = passData
    }

    internal enum CodingKeys: String, CodingKey {
        case passBase64String = "passData"
    }
}
