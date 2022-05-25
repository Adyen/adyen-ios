//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation

internal struct Submit3DS2FingerprintResponse: Response {

    internal let result: ThreeDSActionHandlerResult

    internal init(result: ThreeDSActionHandlerResult) {
        self.result = result
    }

    internal init(from decoder: Decoder) throws {
        self.result = try ThreeDSActionHandlerResult(from: decoder)
    }
}
