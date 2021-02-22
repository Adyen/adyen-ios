//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

public struct AppleWalletPassResponse: Response {

    /// :nodoc:
    /// The payload.
    public let appleWalletPassBundle: Data?

    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base64 = try container.decode(String.self, forKey: .appleWalletPassBundle)
        appleWalletPassBundle = Data(base64Encoded: base64)
    }

    /// :nodoc:
    private enum CodingKeys: String, CodingKey {
        case appleWalletPassBundle
    }
}
