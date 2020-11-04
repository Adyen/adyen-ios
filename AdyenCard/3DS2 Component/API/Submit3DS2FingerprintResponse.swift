//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// :nodoc:
internal struct Submit3DS2FingerprintResponse: Response {

    internal let resultCode: ResultCode

    internal let action: Action?

    internal init(resultCode: ResultCode, action: Action?) {
        self.resultCode = resultCode
        self.action = action
    }

    private enum CodingKeys: String, CodingKey {
        case resultCode
        case action
    }
}

internal enum ResultCode: String, Decodable {
    case authorised = "Authorised"
    case refused = "Refused"
    case pending = "Pending"
    case cancelled = "Cancelled"
    case error = "Error"
    case received = "Received"
    case redirectShopper = "RedirectShopper"
    case identifyShopper = "IdentifyShopper"
    case challengeShopper = "ChallengeShopper"
}
