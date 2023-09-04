//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

/// :nodoc:
struct Submit3DS2FingerprintResponse: Response {

    let result: ThreeDSActionHandlerResult

    init(result: ThreeDSActionHandlerResult) {
        self.result = result
    }

    init(from decoder: Decoder) throws {
        self.result = try ThreeDSActionHandlerResult(from: decoder)
    }
}
