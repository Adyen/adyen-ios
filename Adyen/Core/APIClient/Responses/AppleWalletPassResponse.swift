//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
public struct AppleWalletPassResponse: Response {

    /// :nodoc:
    public let passBase64String: String

    /// :nodoc:
    public lazy var passData: Data? = Data(base64Encoded: passBase64String)

    /// :nodoc:
    public init(passBase64String: String) {
        self.passBase64String = passBase64String
    }

    /// :nodoc:
    internal enum CodingKeys: String, CodingKey {
        case passBase64String = "passData"
    }
}
