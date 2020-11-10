//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// :nodoc:
internal struct Submit3DS2FingerprintResponse: Response {

    internal let action: Action

    internal init(action: Action) {
        self.action = action
    }

    private enum CodingKeys: String, CodingKey {
        case action
    }
}
