//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
@_spi(AdyenInternal) import Adyen

internal protocol Payload: Encodable {
    func jsonData() throws -> Data
}

extension Payload {
    internal func jsonData() throws -> Data {
        return try AdyenCoder.encode(self)
    }
}
